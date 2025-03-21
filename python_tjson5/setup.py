from setuptools import setup, Extension
from Cython.Build import cythonize
import os

# Read the README.md file for the long description
with open(os.path.join(os.path.dirname(__file__), "README.md"), "r") as f:
    long_description = f.read()

extensions = [
    Extension(
        "tjson5parser",
        ["tjson5parser.pyx"],
        language="c",
    ),
]

setup(
    name="tjson5",
    version="0.1.0",
    description="Triple-JSON5 parser for Python",
    long_description=long_description,
    long_description_content_type="text/markdown",
    author="Kristof Mulier",
    author_email="kristof.mulier@example.com",
    url="https://github.com/kristofmulier/triple-json5",
    ext_modules=cythonize(extensions, language_level=3),
    python_requires=">=3.7",
    classifiers=[
        "Development Status :: 4 - Beta",
        "Intended Audience :: Developers",
        "License :: OSI Approved :: MIT License",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.7",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: Implementation :: CPython",
        "Topic :: Software Development :: Libraries :: Python Modules",
    ],
)