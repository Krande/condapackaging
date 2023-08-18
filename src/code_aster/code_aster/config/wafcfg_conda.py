import os


def configure(self):
    opts = self.options

    print('Running Conda Configuration')

    conda_prefix = os.getenv('PREFIX')
    recipe_dir = os.getenv('RECIPE_DIR')

    self.env.WAFBUILD_ENV = [recipe_dir + '/config/dummy.env', conda_prefix]

    self.env.append_value('LIBPATH', [
        conda_prefix + '/lib',
    ])

    self.env.append_value('INCLUDES', [
        conda_prefix + "/include",
        conda_prefix + '/include_seq',
    ])

    # to fail if not found
    opts.enable_hdf5 = True
    opts.enable_med = True
    opts.enable_metis = True
    opts.enable_mumps = True
    opts.enable_scotch = True
    opts.enable_mfront = True
    opts.enable_homard = True
    opts.enable_petsc = True
    opts.with_py_medcoupling = True
    print('Conda Configuration Complete')
