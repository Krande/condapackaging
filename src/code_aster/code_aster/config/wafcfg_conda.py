import os


def configure(self):
    opts = self.options

    print('Running Conda Configuration')

    include_dir = os.getenv('CONDA_INCLUDE_PATH')
    lib_dir = os.getenv('CONDA_LIBRARY_PATH')
    conda_prefix = os.getenv('CONDA_PREFIX')
    prefix_dir = os.getenv("PREFIX")
    recipe_dir = os.getenv('RECIPE_DIR')

    self.env['ADDMEM'] = 600

    self.env.INCLUDES_BOOST = include_dir
    self.env.LIBPATH_BOOST = [lib_dir]
    self.env.LIB_BOOST = ['libboost_python310']
    self.env.TFELHOME = [conda_prefix, conda_prefix + '/bin']

    self.env.LIBPATH_METIS = [lib_dir, prefix_dir + '/metis-aster', prefix_dir + '/metis-aster/lib']
    self.env.INCLUDES_METIS = [include_dir, prefix_dir + '/metis-aster/include']

    self.env.WAFBUILD_ENV = [recipe_dir + '/config/dummy.env', conda_prefix]

    self.env.append_value('LIBPATH', [
        lib_dir,
        prefix_dir + '/metis-aster'
    ])

    self.env.append_value('INCLUDES', [
        include_dir,
    ])

    # to fail if not found
    opts.enable_hdf5 = True
    opts.enable_med = True
    opts.enable_metis = True
    opts.enable_mumps = True
    opts.enable_scotch = True
    opts.enable_mfront = True
    print('Conda Configuration Complete')
