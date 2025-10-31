#! /usr/bin/env python
# encoding: utf-8
# WARNING! Do not edit! https://waf.io/book/index.html#_obtaining_the_waf_file

import os, re, traceback
import pathlib

from waflib import Utils, Logs, Errors
from waflib.Tools import fc, fc_config, fc_scan, ar, ccroot
from waflib.Configure import conf
from waflib.TaskGen import after_method, feature


@conf
def find_ifort(conf):
    fc = conf.find_program(['ifx', 'ifort'], var='FC')
    conf.get_ifort_version(fc)
    conf.env.FC_NAME = 'IFORT'


@conf
def ifort_modifier_win32(self):
    v = self.env
    v.IFORT_WIN32 = True
    v.FCSTLIB_MARKER = ''
    v.FCSHLIB_MARKER = ''
    v.FCLIB_ST = v.FCSTLIB_ST = '%s.lib'
    v.FCLIBPATH_ST = v.STLIBPATH_ST = '/LIBPATH:%s'
    v.FCINCPATH_ST = '/I%s'
    v.FCDEFINES_ST = '/D%s'
    v.fcprogram_PATTERN = v.fcprogram_test_PATTERN = '%s.exe'
    v.fcshlib_PATTERN = '%s.dll'
    v.fcstlib_PATTERN = v.implib_PATTERN = '%s.lib'
    v.FCLNK_TGT_F = '/out:'
    v.FC_TGT_F = ['/c', '/o', '']
    v.FCFLAGS_fcshlib = ''
    v.LINKFLAGS_fcshlib = '/DLL'
    v.AR_TGT_F = '/out:'
    v.IMPLIB_ST = '/IMPLIB:%s'
    v.append_value('LINKFLAGS', '/subsystem:console')
    if v.IFORT_MANIFEST:
        v.append_value('LINKFLAGS', ['/MANIFEST'])


@conf
def ifort_modifier_darwin(conf):
    fc_config.fortran_modifier_darwin(conf)


@conf
def ifort_modifier_platform(conf):
    dest_os = conf.env.DEST_OS or Utils.unversioned_sys_platform()
    ifort_modifier_func = getattr(conf, 'ifort_modifier_' + dest_os, None)
    if ifort_modifier_func:
        ifort_modifier_func()


@conf
def get_ifort_version(conf, fc):
    version_re = re.compile(r"\bIntel\b.*\bVersion\s*(?P<major>\d*)\.(?P<minor>\d*)", re.I).search
    if Utils.is_win32:
        cmd = fc
    else:
        cmd = fc + ['-logo']
    out, err = fc_config.getoutput(conf, cmd, stdin=False)
    match = version_re(out) or version_re(err)
    if not match:
        conf.fatal('cannot determine ifort version.')
    k = match.groupdict()
    conf.env.FC_VERSION = (k['major'], k['minor'])


def configure(conf):
    if Utils.is_win32:
        compiler, version, path, includes, libdirs, arch = conf.detect_ifort()
        v = conf.env
        v.DEST_CPU = arch
        v.PATH = path
        v.INCLUDES = includes
        v.LIBPATH = libdirs
        v.MSVC_COMPILER = compiler
        try:
            v.MSVC_VERSION = float(version)
        except ValueError:
            v.MSVC_VERSION = float(version[:-3])
        conf.find_ifort_win32()
        conf.ifort_modifier_win32()
    else:
        conf.find_ifort()
        conf.find_program('xiar', var='AR')
        conf.find_ar()
        conf.fc_flags()
        conf.fc_add_flags()
        conf.ifort_modifier_platform()


all_ifort_platforms = [('intel64', 'amd64'), ('em64t', 'amd64'), ('ia32', 'x86')]


@conf
def gather_ifort_versions(conf, versions):
    # Check if we're in a conda build with Intel Fortran already configured
    conda_intel = os.getenv("CONDA_BUILD_INTEL_FORTRAN")
    ifort_version = os.getenv("INTEL_FORTRAN_VERSION", "2025.1162")

    if conda_intel:
        # Conda-based Intel Fortran - paths are already set, just verify compiler exists
        Logs.info(f"Detecting conda-based Intel Fortran compiler")

        # Try to find ifx in PATH
        ifx_path = conf.find_program(['ifx', 'ifort'], var='FC_TEST', mandatory=False)
        if ifx_path:
            Logs.info(f"Found Intel Fortran compiler in PATH")

            # Get current PATH, LIB, and INCLUDE from environment
            current_path = os.getenv('PATH', '').split(';')
            current_lib = os.getenv('LIB', '').split(';')
            current_include = os.getenv('INCLUDE', '').split(';')

            arch = 'amd64'
            version = ifort_version
            target = 'intel64'

            # Create a conda-aware target_compiler
            tc = target_compiler(conf, 'intel', arch, version, target, None)
            tc.is_conda = True
            tc.conda_paths = (current_path, current_include, current_lib)
            targets = dict(intel64=tc)
            major = version[0:2]
            versions['intel ' + major] = targets
            return

    # Try environment variable pointing to vars.bat
    intel_vars_path = os.getenv("INTEL_VARS_PATH")
    if intel_vars_path:
        ifort_batch_file = pathlib.Path(intel_vars_path + '\\vars.bat')
        if ifort_batch_file.exists():
            Logs.info(f"Using ifort batch file: {ifort_batch_file}")
            arch = 'amd64'
            version = ifort_version
            target = 'intel64'
            targets = dict(intel64=target_compiler(conf, 'intel', arch, version, target, ifort_batch_file.as_posix()))
            major = version[0:2]
            versions['intel ' + major] = targets
            return

    version_pattern = re.compile(r'^...?.?\....?.?')
    try:
        all_versions = Utils.winreg.OpenKey(Utils.winreg.HKEY_LOCAL_MACHINE,
                                            'SOFTWARE\\Wow6432node\\Intel\\Compilers\\1AFortran')
    except OSError:
        try:
            all_versions = Utils.winreg.OpenKey(Utils.winreg.HKEY_LOCAL_MACHINE, 'SOFTWARE\\Intel\\Compilers\\Fortran')
        except OSError:
            return

    index = 0
    while 1:
        try:
            version = Utils.winreg.EnumKey(all_versions, index)
        except OSError:
            break
        index += 1
        if not version_pattern.match(version):
            continue
        targets = {}

        for target, arch in all_ifort_platforms:
            if target == 'intel64':
                targetDir = 'EM64T_NATIVE'
            else:
                targetDir = target
            try:
                Utils.winreg.OpenKey(all_versions, version + '\\' + targetDir)
                icl_version = Utils.winreg.OpenKey(all_versions, version)
                path, type = Utils.winreg.QueryValueEx(icl_version, 'ProductDir')
            except OSError:
                pass
            else:
                batch_file = os.path.join(path, 'bin', 'ifortvars.bat')
                if os.path.isfile(batch_file):
                    targets[target] = target_compiler(conf, 'intel', arch, version, target, batch_file)
                else:
                    batch_file = os.path.join(path, 'env', 'vars.bat')
                    if os.path.isfile(batch_file):
                        # Logs.info(f"{conf=}, {arch=}, {version=}, {target=}, {batch_file=}")
                        targets[target] = target_compiler(conf, 'intel', arch, version, target, batch_file)
        for target, arch in all_ifort_platforms:
            try:
                icl_version = Utils.winreg.OpenKey(all_versions, version + '\\' + target)
                path, type = Utils.winreg.QueryValueEx(icl_version, 'ProductDir')
            except OSError:
                continue
            else:
                batch_file = os.path.join(path, 'bin', 'ifortvars.bat')
                if os.path.isfile(batch_file):
                    targets[target] = target_compiler(conf, 'intel', arch, version, target, batch_file)
        major = version[0:2]
        versions['intel ' + major] = targets


@conf
def setup_ifort(conf, versiondict):
    platforms = Utils.to_list(conf.env.MSVC_TARGETS) or [i for i, j in all_ifort_platforms]
    desired_versions = conf.env.MSVC_VERSIONS or list(reversed(list(versiondict.keys())))
    for version in desired_versions:
        try:
            targets = versiondict[version]
        except KeyError:
            continue
        for arch in platforms:
            try:
                cfg = targets[arch]
            except KeyError:
                continue
            cfg.evaluate()
            if cfg.is_valid:
                compiler, revision = version.rsplit(' ', 1)
                return compiler, revision, cfg.bindirs, cfg.incdirs, cfg.libdirs, cfg.cpu

    conf.fatal('ifort: Impossible to find a valid architecture for building %r - %r' % (
        desired_versions, list(versiondict.keys())))


@conf
def get_ifort_version_win32(conf, compiler, version, target, vcvars):
    try:
        conf.msvc_cnt += 1
    except AttributeError:
        conf.msvc_cnt = 1
    batfile = conf.bldnode.make_node('waf-print-msvc-%d.bat' % conf.msvc_cnt)
    batfile.write("""@echo off
setlocal enabledelayedexpansion
:: if SETVARS_CALL is defined, then the script is being called from another script
:: and we should not set the environment variables
if not defined SETVARS_COMPLETED (
    set INCLUDE=
    set LIB=
    call "%s" %s
) else (
    echo Environment variables already set
)

echo PATH=%%PATH%%
echo INCLUDE=%%INCLUDE%%
echo LIB=%%LIB%%;%%LIBPATH%%
endlocal
""" % (vcvars, target))
    sout = conf.cmd_and_log(['cmd.exe', '/E:on', '/V:on', '/C', batfile.abspath()])
    batfile.delete()
    lines = sout.splitlines()
    if not lines[0]:
        lines.pop(0)
    MSVC_PATH = MSVC_INCDIR = MSVC_LIBDIR = None
    for line in lines:
        if line.startswith('PATH='):
            path = line[5:]
            MSVC_PATH = path.split(';')
        elif line.startswith('INCLUDE='):
            MSVC_INCDIR = [i for i in line[8:].split(';') if i]
        elif line.startswith('LIB='):
            MSVC_LIBDIR = [i for i in line[4:].split(';') if i]
    if None in (MSVC_PATH, MSVC_INCDIR, MSVC_LIBDIR):
        conf.fatal('ifort: Could not find a valid architecture for building (get_ifort_version_win32)')
    env = dict(os.environ)
    env.update(PATH=path)
    compiler_name, linker_name, lib_name = _get_prog_names(conf, compiler)
    fc = conf.find_program(compiler_name, path_list=MSVC_PATH)
    if 'CL' in env:
        del (env['CL'])
    try:
        conf.cmd_and_log(fc + ['/help'], env=env)
    except UnicodeError:
        st = traceback.format_exc()
        if conf.logger:
            conf.logger.error(st)
        conf.fatal('ifort: Unicode error - check the code page?')
    except Exception as e:
        Logs.debug('ifort: get_ifort_version: %r %r %r -> failure %s', compiler, version, target, str(e))
        conf.fatal('ifort: cannot run the compiler in get_ifort_version (run with -v to display errors)')
    else:
        Logs.debug('ifort: get_ifort_version: %r %r %r -> OK', compiler, version, target)
    finally:
        conf.env[compiler_name] = ''
    return (MSVC_PATH, MSVC_INCDIR, MSVC_LIBDIR)


class target_compiler(object):
    def __init__(self, ctx, compiler, cpu, version, bat_target, bat, callback=None):
        self.conf = ctx
        self.name = None
        self.is_valid = False
        self.is_done = False
        self.compiler = compiler
        self.cpu = cpu
        self.version = version
        self.bat_target = bat_target
        self.bat = bat
        self.callback = callback
        self.bindirs = None
        self.incdirs = None
        self.libdirs = None
        self.is_conda = False
        self.conda_paths = None

    def evaluate(self):
        if self.is_done:
            return
        self.is_done = True

        # Handle conda-based compiler
        if self.is_conda and self.conda_paths:
            Logs.info("Using conda-based Intel Fortran environment")
            self.bindirs = [p for p in self.conda_paths[0] if p]
            self.incdirs = [p for p in self.conda_paths[1] if p]
            self.libdirs = [p for p in self.conda_paths[2] if p]
            self.is_valid = True
            return

        # Handle traditional batch file based setup
        try:
            vs = self.conf.get_ifort_version_win32(self.compiler, self.version, self.bat_target, self.bat)
        except Errors.ConfigurationError as e:
            Logs.warn(f"ifort: {e}")
            self.is_valid = False
            return
        if self.callback:
            vs = self.callback(self, vs)
        self.is_valid = True
        (self.bindirs, self.incdirs, self.libdirs) = vs

    def __str__(self):
        return str((self.bindirs, self.incdirs, self.libdirs))

    def __repr__(self):
        return repr((self.bindirs, self.incdirs, self.libdirs))


@conf
def detect_ifort(self):
    return self.setup_ifort(self.get_ifort_versions(False))


@conf
def get_ifort_versions(self, eval_and_save=True):
    dct = {}
    self.gather_ifort_versions(dct)
    return dct


def _get_prog_names(self, compiler):
    if compiler == 'intel':
        compiler_name = 'ifx'
        linker_name = 'XILINK'
        lib_name = 'LIB'
    else:
        compiler_name = 'CL'
        linker_name = 'LINK'
        lib_name = 'LIB'
    return compiler_name, linker_name, lib_name


@conf
def find_ifort_win32(conf):
    v = conf.env
    path = v.PATH
    compiler = v.MSVC_COMPILER
    version = v.MSVC_VERSION
    compiler_name, linker_name, lib_name = _get_prog_names(conf, compiler)
    v.IFORT_MANIFEST = (compiler == 'intel' and version >= 11)
    fc = conf.find_program(compiler_name, var='FC', path_list=path)
    env = dict(conf.environ)
    if path:
        env.update(PATH=';'.join(path))

    # For conda builds, skip the help check as compiler is already validated
    conda_intel = os.getenv("CONDA_BUILD_INTEL_FORTRAN")
    if not conda_intel:
        # Only run help check for non-conda builds
        try:
            if not conf.cmd_and_log(fc + ['/nologo', '/help'], env=env):
                conf.fatal('not intel fortran compiler could not be identified')
        except UnicodeEncodeError:
            # Handle encoding errors in compiler output gracefully
            Logs.warn('ifort: Unicode encoding error in compiler output, skipping validation')

    v.FC_NAME = 'IFORT'
    if not v.LINK_FC:
        conf.find_program(linker_name, var='LINK_FC', path_list=path, mandatory=True)
    if not v.AR:
        conf.find_program(lib_name, path_list=path, var='AR', mandatory=True)
        v.ARFLAGS = ['/nologo']
    if v.IFORT_MANIFEST:
        conf.find_program('MT', path_list=path, var='MT')
        v.MTFLAGS = ['/nologo']
    try:
        conf.load('winres')
    except Errors.WafError:
        Logs.warn('Resource compiler not found. Compiling resource file is disabled')


@after_method('apply_link')
@feature('fc')
def apply_flags_ifort(self):
    if not self.env.IFORT_WIN32 or not getattr(self, 'link_task', None):
        return
    is_static = isinstance(self.link_task, ccroot.stlink_task)
    subsystem = getattr(self, 'subsystem', '')
    if subsystem:
        subsystem = '/subsystem:%s' % subsystem
        flags = is_static and 'ARFLAGS' or 'LINKFLAGS'
        self.env.append_value(flags, subsystem)

    if not is_static:
        for f in self.env.LINKFLAGS:
            d = f.lower()
            if d[1:].startswith('debug'):
                Logs.info(f"Exporting bibfor to pdb")
                pdbnode = self.link_task.outputs[0].change_ext('.pdb')
                self.link_task.outputs.append(pdbnode)
                if getattr(self, 'install_task', None):
                    self.pdb_install_task = self.add_install_files(install_to=self.install_task.install_to,
                                                                   install_from=pdbnode)
                break


@feature('fcprogram', 'fcshlib', 'fcprogram_test')
@after_method('apply_link')
def apply_manifest_ifort(self):
    if self.env.IFORT_WIN32 and getattr(self, 'link_task', None):
        self.link_task.env.FC = self.env.LINK_FC
    if self.env.IFORT_WIN32 and self.env.IFORT_MANIFEST and getattr(self, 'link_task', None):
        out_node = self.link_task.outputs[0]
        man_node = out_node.parent.find_or_declare(out_node.name + '.manifest')
        self.link_task.outputs.append(man_node)
        self.env.DO_MANIFEST = True
