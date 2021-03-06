######################################################################
## gsIntall.cmake ---
## This file is part of the G+Smo library.
## 
## Author: Angelos Mantzaflaris 
## Author: Harald Weiner
## Copyright (C) 2012-2015 - RICAM-Linz.
######################################################################
## Installation
######################################################################

message ("  CMAKE_INSTALL_PREFIX    ${CMAKE_INSTALL_PREFIX}")

set(CMAKE_SKIP_INSTALL_ALL_DEPENDENCY true)

# Offer the user the choice of overriding the installation directories
set(LIB_INSTALL_DIR     lib     CACHE PATH "Installation directory for libraries")
set(BIN_INSTALL_DIR     bin     CACHE PATH "Installation directory for executables")
set(INCLUDE_INSTALL_DIR include CACHE PATH "Installation directory for header files")
SET(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/${LIB_INSTALL_DIR}")

# Set CMake installation directory
if(WIN32 AND NOT CYGWIN)
  set(DEF_INSTALL_CMAKE_DIR ${LIB_INSTALL_DIR}/cmake)
else()
   set(DEF_INSTALL_CMAKE_DIR ${LIB_INSTALL_DIR})
endif()
set(INSTALL_CMAKE_DIR ${DEF_INSTALL_CMAKE_DIR} CACHE PATH
  "Installation directory for CMake files")

# Make relative paths absolute (needed later on)
foreach(p LIB BIN INCLUDE CMAKE)
  set(var INSTALL_${p}_DIR)
  if(NOT IS_ABSOLUTE "${${var}}")
    set(${var} "${CMAKE_INSTALL_PREFIX}/${${var}}")
  endif()
endforeach()

# Add all targets to the build-tree export set
if(GISMO_BUILD_LIB)
export(TARGETS ${PROJECT_NAME}
  FILE "${PROJECT_BINARY_DIR}/gismoTargets.cmake" APPEND)
endif()

#if(GISMO_WITH_other)
#  export(TARGETS other
#    FILE "${PROJECT_BINARY_DIR}/gismoTargets.cmake" APPEND)
#endif()

# Export the package for use from the build-tree
# (this registers the build-tree with a global CMake-registry)
export(PACKAGE gismo)

# Create the gismoConfig.cmake and gismoConfigVersion.cmake files

# ... for the build tree
set(CONF_INCLUDE_DIRS "${GISMO_INCLUDE_DIRS}"
                      "${PROJECT_BINARY_DIR}" )
set(CONF_LIB_DIRS     "${CMAKE_BINARY_DIR}/lib")
set(CONF_USE_FILE     "${CMAKE_BINARY_DIR}/gismoUse.cmake")
configure_file(${PROJECT_SOURCE_DIR}/cmake/gismoConfig.cmake.in
              "${CMAKE_BINARY_DIR}/gismoConfig.cmake" @ONLY)
file(COPY ${PROJECT_SOURCE_DIR}/cmake/gismoUse.cmake DESTINATION ${CMAKE_BINARY_DIR})

# ... for the install tree
set(CONF_INCLUDE_DIRS "${CMAKE_INSTALL_PREFIX}/${INCLUDE_INSTALL_DIR}/${PROJECT_NAME}")
set(CONF_LIB_DIRS     "${CMAKE_INSTALL_PREFIX}/${LIB_INSTALL_DIR}")
set(CONF_USE_FILE     "${INSTALL_CMAKE_DIR}/gismoUse.cmake")
configure_file(${PROJECT_SOURCE_DIR}/cmake/gismoConfig.cmake.in
              "${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/gismoConfig.cmake" @ONLY)

# ... for both
configure_file(${PROJECT_SOURCE_DIR}/cmake/gismoConfigVersion.cmake.in
  "${CMAKE_BINARY_DIR}/gismoConfigVersion.cmake" @ONLY)

if(GISMO_BUILD_LIB)

set_target_properties(gismo PROPERTIES
  PUBLIC_HEADER "${PROJECT_SOURCE_DIR}/src/gismo.h")

# For gsExport.h
install(FILES ${PROJECT_BINARY_DIR}/gsCore/gsExport.h
        DESTINATION include/${PROJECT_NAME}/gsCore)

# For gsLinearAlgebra.h
install(DIRECTORY ${PROJECT_SOURCE_DIR}/external/Eigen
        DESTINATION include/${PROJECT_NAME}
        PATTERN "*.txt" EXCLUDE
        PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ
        )

# For gsCmdLine.h
install(DIRECTORY ${PROJECT_SOURCE_DIR}/external/tclap
        DESTINATION include/${PROJECT_NAME} 
        FILES_MATCHING
        PATTERN "*.h"
        PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ)

# For eiquadprog.hpp
install(FILES ${PROJECT_SOURCE_DIR}/external/eiquadprog.hpp
        DESTINATION include/${PROJECT_NAME} )

# For gsXmlUtils.h
install(FILES ${PROJECT_SOURCE_DIR}/external/rapidxml/rapidxml.hpp
              ${PROJECT_SOURCE_DIR}/external/rapidxml/rapidxml_print.hpp	
        DESTINATION include/${PROJECT_NAME}/rapidxml/)


# For pure install
#install(DIRECTORY ${PROJECT_SOURCE_DIR}/external/rapidxml
#        DESTINATION include/${PROJECT_NAME}
#        FILES_MATCHING
#        PATTERN "*.hpp"
#        PATTERN ".svn" EXCLUDE
#        PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ)

# For gsConfig.h
install(DIRECTORY ${GISMO_DATA_DIR} DESTINATION share/gismodata)
# todo: search environment variable as well
set(GISMO_DATA_DIR ${CMAKE_INSTALL_PREFIX}/share/gismodata/)
configure_file ("${PROJECT_SOURCE_DIR}/src/gsCore/gsConfig.h.in"
                "${PROJECT_BINARY_DIR}/gsCore/gsConfig_install.h" )
install(FILES ${PROJECT_BINARY_DIR}/gsCore/gsConfig_install.h
        DESTINATION include/${PROJECT_NAME}/gsCore/ RENAME gsConfig.h)

# Install cmake files
install(FILES
  "${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/gismoConfig.cmake"
  "${CMAKE_BINARY_DIR}/gismoConfigVersion.cmake"
  "${PROJECT_SOURCE_DIR}/cmake/gismoUse.cmake"
  DESTINATION "${INSTALL_CMAKE_DIR}" COMPONENT dev)
 
# Install the export set for use with the install-tree
#install(EXPORT gismoTargets DESTINATION
#  "${INSTALL_CMAKE_DIR}" COMPONENT dev)

else(GISMO_BUILD_LIB)
   message ("Configure with -DGISMO_BUILD_LIB=ON to compile the library")
endif(GISMO_BUILD_LIB)

# Install docs (if available)
set(DOC_SRC_DIR "${PROJECT_BINARY_DIR}/doc/html/")
#message("DOC_SRC_DIR='${DOC_SRC_DIR}'")

set(TMP_VERSION "${gismo_VERSION}")
string(REGEX REPLACE "[a-zA-Z]+" "" TMP_VERSION ${TMP_VERSION})
#message("TMP_VERSION='${TMP_VERSION}'")
set(DOC_INSTALL_DIR share/doc/gismo-${TMP_VERSION} CACHE PATH 
			"Installation directory for documentation")
#message("DOC_INSTALL_DIR='${DOC_INSTALL_DIR}'")

install(DIRECTORY "${DOC_SRC_DIR}"
		DESTINATION "${DOC_INSTALL_DIR}/"
		USE_SOURCE_PERMISSIONS
		OPTIONAL 
		FILES_MATCHING
			PATTERN "*.css"
			PATTERN "*.html"
			PATTERN "*.js"
			PATTERN "*.jpg"
			PATTERN "*.png"
)
