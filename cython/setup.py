from setuptools import setup, Extension
from Cython.Build import cythonize

quirc_extension = Extension(
            name='py_quirc',
            sources=['py_quirc.pyx'],
            libraries=['quircapi'],
            library_dirs=['../lib'],
            include_dirs=['../lib']
)

setup(
    name='py_quirc',
	ext_modules=cythonize([quirc_extension])
)
