# Copyright (c) 2018, Intel Corporation
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

add_library(${BUILTINS_BINARIES_LIB_NAME} OBJECT CMakeLists.txt)

# Add builtins sources
add_subdirectory(registry)

set(GENERATED_BUILTINS "COPY_BUFFER_TO_BUFFER"
                       "COPY_BUFFER_RECT"
                       "FILL_BUFFER"
                       "COPY_BUFFER_TO_IMAGE3D"
                       "COPY_IMAGE3D_TO_BUFFER"
                       "COPY_IMAGE_TO_IMAGE1D"
                       "COPY_IMAGE_TO_IMAGE2D"
                       "COPY_IMAGE_TO_IMAGE3D"
                       "FILL_IMAGE1D"
                       "FILL_IMAGE2D"
                       "FILL_IMAGE3D"
)

# Generate builtins cpps
if(COMPILE_BUILT_INS)
  add_subdirectory(kernels)
endif()

foreach(GEN_NUM RANGE ${MAX_GEN})
  GEN_CONTAINS_PLATFORMS("SUPPORTED" ${GEN_NUM} GENX_HAS_PLATFORMS)
  if(${GENX_HAS_PLATFORMS})
    # Get all supported platforms for this GEN
    GET_PLATFORMS_FOR_GEN("SUPPORTED" ${GEN_NUM} SUPPORTED_GENX_PLATFORMS)

    # Add platform-specific files
    foreach(PLATFORM_IT ${SUPPORTED_GENX_PLATFORMS})
      foreach(GENERATED_BUILTIN ${GENERATED_BUILTINS})
        list(APPEND GENERATED_BUILTINS_CPPS ${BUILTINS_INCLUDE_DIR}/${RUNTIME_GENERATED_${GENERATED_BUILTIN}_GEN${GEN_NUM}_${PLATFORM_IT}})
      endforeach(GENERATED_BUILTIN)
    endforeach(PLATFORM_IT)

    source_group("generated files\\gen${GEN_NUM}" FILES ${GENERATED_BUILTINS_CPPS})
  endif(${GENX_HAS_PLATFORMS})
endforeach(GEN_NUM)

if(COMPILE_BUILT_INS)
  target_sources(${BUILTINS_BINARIES_LIB_NAME} PUBLIC ${GENERATED_BUILTINS_CPPS})
  set_source_files_properties(${GENERATED_BUILTINS_CPPS} PROPERTIES GENERATED TRUE)
endif(COMPILE_BUILT_INS)

set_target_properties(${BUILTINS_BINARIES_LIB_NAME} PROPERTIES LINKER_LANGUAGE CXX)
set_target_properties(${BUILTINS_BINARIES_LIB_NAME} PROPERTIES POSITION_INDEPENDENT_CODE ON)
set_target_properties(${BUILTINS_BINARIES_LIB_NAME} PROPERTIES FOLDER "built_ins")

target_include_directories(${BUILTINS_BINARIES_LIB_NAME} PRIVATE
  ${KHRONOS_HEADERS_DIR}
  ${UMKM_SHAREDDATA_INCLUDE_PATHS}
  ${IGDRCL__IGC_INCLUDE_DIR}
  ${THIRD_PARTY_DIR}
)
