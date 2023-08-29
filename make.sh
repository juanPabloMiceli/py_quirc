# Compile C library
cd lib/
gcc -c -fPIC *.c
sudo ar rcs libquircapi.a

# Remove old files
cd ../cython/
rm py_quirc.so || true

# Generate .so library
python setup.py build_ext --inplace
