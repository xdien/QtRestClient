if (CMAKE_VERSION VERSION_LESS 3.1.0)
    message(FATAL_ERROR "Qt 5 RestClient module requires at least CMake version 3.1.0")
endif()

get_filename_component(_qt5RestClient_install_prefix "${CMAKE_CURRENT_LIST_DIR}/../../../" ABSOLUTE)

# For backwards compatibility only. Use Qt5RestClient_VERSION instead.
set(Qt5RestClient_VERSION_STRING 3.0.0)

set(Qt5RestClient_LIBRARIES Qt5::RestClient)

macro(_qt5_RestClient_check_file_exists file)
    if(NOT EXISTS "${file}" )
        message(FATAL_ERROR "The imported target \"Qt5::RestClient\" references the file
   \"${file}\"
but this file does not exist.  Possible reasons include:
* The file was deleted, renamed, or moved to another location.
* An install or uninstall procedure did not complete successfully.
* The installation package was faulty and contained
   \"${CMAKE_CURRENT_LIST_FILE}\"
but not all the files it references.
")
    endif()
endmacro()


macro(_populate_RestClient_target_properties Configuration LIB_LOCATION IMPLIB_LOCATION
      IsDebugAndRelease)
    set_property(TARGET Qt5::RestClient APPEND PROPERTY IMPORTED_CONFIGURATIONS ${Configuration})

    set(imported_location "${_qt5RestClient_install_prefix}/bin/${LIB_LOCATION}")
    _qt5_RestClient_check_file_exists(${imported_location})
    set(_deps
        ${_Qt5RestClient_LIB_DEPENDENCIES}
    )
    set(_static_deps
    )

    set_target_properties(Qt5::RestClient PROPERTIES
        "IMPORTED_LOCATION_${Configuration}" ${imported_location}
        # For backward compatibility with CMake < 2.8.12
        "IMPORTED_LINK_INTERFACE_LIBRARIES_${Configuration}" "${_deps};${_static_deps}"
    )
    set_property(TARGET Qt5::RestClient APPEND PROPERTY INTERFACE_LINK_LIBRARIES
                 "${_deps}"
    )


    set(imported_implib "${_qt5RestClient_install_prefix}/lib/${IMPLIB_LOCATION}")
    _qt5_RestClient_check_file_exists(${imported_implib})
    if(NOT "${IMPLIB_LOCATION}" STREQUAL "")
        set_target_properties(Qt5::RestClient PROPERTIES
        "IMPORTED_IMPLIB_${Configuration}" ${imported_implib}
        )
    endif()
endmacro()

if (NOT TARGET Qt5::RestClient)

    set(_Qt5RestClient_OWN_INCLUDE_DIRS "${_qt5RestClient_install_prefix}/include/" "${_qt5RestClient_install_prefix}/include/QtRestClient")
    set(Qt5RestClient_PRIVATE_INCLUDE_DIRS
        "${_qt5RestClient_install_prefix}/include/QtRestClient/3.0.0"
        "${_qt5RestClient_install_prefix}/include/QtRestClient/3.0.0/QtRestClient"
    )

    foreach(_dir ${_Qt5RestClient_OWN_INCLUDE_DIRS})
        _qt5_RestClient_check_file_exists(${_dir})
    endforeach()

    # Only check existence of private includes if the Private component is
    # specified.
    list(FIND Qt5RestClient_FIND_COMPONENTS Private _check_private)
    if (NOT _check_private STREQUAL -1)
        foreach(_dir ${Qt5RestClient_PRIVATE_INCLUDE_DIRS})
            _qt5_RestClient_check_file_exists(${_dir})
        endforeach()
    endif()

    set(Qt5RestClient_INCLUDE_DIRS ${_Qt5RestClient_OWN_INCLUDE_DIRS})

    set(Qt5RestClient_DEFINITIONS -DQT_RESTCLIENT_LIB)
    set(Qt5RestClient_COMPILE_DEFINITIONS QT_RESTCLIENT_LIB)
    set(_Qt5RestClient_MODULE_DEPENDENCIES "Network;JsonSerializer;Core")


    set(Qt5RestClient_OWN_PRIVATE_INCLUDE_DIRS ${Qt5RestClient_PRIVATE_INCLUDE_DIRS})

    set(_Qt5RestClient_FIND_DEPENDENCIES_REQUIRED)
    if (Qt5RestClient_FIND_REQUIRED)
        set(_Qt5RestClient_FIND_DEPENDENCIES_REQUIRED REQUIRED)
    endif()
    set(_Qt5RestClient_FIND_DEPENDENCIES_QUIET)
    if (Qt5RestClient_FIND_QUIETLY)
        set(_Qt5RestClient_DEPENDENCIES_FIND_QUIET QUIET)
    endif()
    set(_Qt5RestClient_FIND_VERSION_EXACT)
    if (Qt5RestClient_FIND_VERSION_EXACT)
        set(_Qt5RestClient_FIND_VERSION_EXACT EXACT)
    endif()

    set(Qt5RestClient_EXECUTABLE_COMPILE_FLAGS "")

    foreach(_module_dep ${_Qt5RestClient_MODULE_DEPENDENCIES})
        if (NOT Qt5${_module_dep}_FOUND)
            find_package(Qt5${_module_dep}
                3.0.0 ${_Qt5RestClient_FIND_VERSION_EXACT}
                ${_Qt5RestClient_DEPENDENCIES_FIND_QUIET}
                ${_Qt5RestClient_FIND_DEPENDENCIES_REQUIRED}
                PATHS "${CMAKE_CURRENT_LIST_DIR}/.." NO_DEFAULT_PATH
            )
        endif()

        if (NOT Qt5${_module_dep}_FOUND)
            set(Qt5RestClient_FOUND False)
            return()
        endif()

        list(APPEND Qt5RestClient_INCLUDE_DIRS "${Qt5${_module_dep}_INCLUDE_DIRS}")
        list(APPEND Qt5RestClient_PRIVATE_INCLUDE_DIRS "${Qt5${_module_dep}_PRIVATE_INCLUDE_DIRS}")
        list(APPEND Qt5RestClient_DEFINITIONS ${Qt5${_module_dep}_DEFINITIONS})
        list(APPEND Qt5RestClient_COMPILE_DEFINITIONS ${Qt5${_module_dep}_COMPILE_DEFINITIONS})
        list(APPEND Qt5RestClient_EXECUTABLE_COMPILE_FLAGS ${Qt5${_module_dep}_EXECUTABLE_COMPILE_FLAGS})
    endforeach()
    list(REMOVE_DUPLICATES Qt5RestClient_INCLUDE_DIRS)
    list(REMOVE_DUPLICATES Qt5RestClient_PRIVATE_INCLUDE_DIRS)
    list(REMOVE_DUPLICATES Qt5RestClient_DEFINITIONS)
    list(REMOVE_DUPLICATES Qt5RestClient_COMPILE_DEFINITIONS)
    list(REMOVE_DUPLICATES Qt5RestClient_EXECUTABLE_COMPILE_FLAGS)

    # It can happen that the same FooConfig.cmake file is included when calling find_package()
    # on some Qt component. An example of that is when using a Qt static build with auto inclusion
    # of plugins:
    #
    # Qt5WidgetsConfig.cmake -> Qt5GuiConfig.cmake -> Qt5Gui_QSvgIconPlugin.cmake ->
    # Qt5SvgConfig.cmake -> Qt5WidgetsConfig.cmake ->
    # finish processing of second Qt5WidgetsConfig.cmake ->
    # return to first Qt5WidgetsConfig.cmake ->
    # add_library cannot create imported target Qt5::Widgets.
    #
    # Make sure to return early in the original Config inclusion, because the target has already
    # been defined as part of the second inclusion.
    if(TARGET Qt5::RestClient)
        return()
    endif()

    set(_Qt5RestClient_LIB_DEPENDENCIES "Qt5::Network;Qt5::JsonSerializer;Qt5::Core")


    add_library(Qt5::RestClient SHARED IMPORTED)


    set_property(TARGET Qt5::RestClient PROPERTY
      INTERFACE_INCLUDE_DIRECTORIES ${_Qt5RestClient_OWN_INCLUDE_DIRS})
    set_property(TARGET Qt5::RestClient PROPERTY
      INTERFACE_COMPILE_DEFINITIONS QT_RESTCLIENT_LIB)

    set_property(TARGET Qt5::RestClient PROPERTY INTERFACE_QT_ENABLED_FEATURES )
    set_property(TARGET Qt5::RestClient PROPERTY INTERFACE_QT_DISABLED_FEATURES )

    # Qt 6 forward compatible properties.
    set_property(TARGET Qt5::RestClient
                 PROPERTY QT_ENABLED_PUBLIC_FEATURES
                 )
    set_property(TARGET Qt5::RestClient
                 PROPERTY QT_DISABLED_PUBLIC_FEATURES
                 )
    set_property(TARGET Qt5::RestClient
                 PROPERTY QT_ENABLED_PRIVATE_FEATURES
                 )
    set_property(TARGET Qt5::RestClient
                 PROPERTY QT_DISABLED_PRIVATE_FEATURES
                 )

    set_property(TARGET Qt5::RestClient PROPERTY INTERFACE_QT_PLUGIN_TYPES "")

    set(_Qt5RestClient_PRIVATE_DIRS_EXIST TRUE)
    foreach (_Qt5RestClient_PRIVATE_DIR ${Qt5RestClient_OWN_PRIVATE_INCLUDE_DIRS})
        if (NOT EXISTS ${_Qt5RestClient_PRIVATE_DIR})
            set(_Qt5RestClient_PRIVATE_DIRS_EXIST FALSE)
        endif()
    endforeach()

    if (_Qt5RestClient_PRIVATE_DIRS_EXIST)
        add_library(Qt5::RestClientPrivate INTERFACE IMPORTED)
        set_property(TARGET Qt5::RestClientPrivate PROPERTY
            INTERFACE_INCLUDE_DIRECTORIES ${Qt5RestClient_OWN_PRIVATE_INCLUDE_DIRS}
        )
        set(_Qt5RestClient_PRIVATEDEPS)
        foreach(dep ${_Qt5RestClient_LIB_DEPENDENCIES})
            if (TARGET ${dep}Private)
                list(APPEND _Qt5RestClient_PRIVATEDEPS ${dep}Private)
            endif()
        endforeach()
        set_property(TARGET Qt5::RestClientPrivate PROPERTY
            INTERFACE_LINK_LIBRARIES Qt5::RestClient ${_Qt5RestClient_PRIVATEDEPS}
        )

        # Add a versionless target, for compatibility with Qt6.
        if(NOT "${QT_NO_CREATE_VERSIONLESS_TARGETS}" AND NOT TARGET Qt::RestClientPrivate)
            add_library(Qt::RestClientPrivate INTERFACE IMPORTED)
            set_target_properties(Qt::RestClientPrivate PROPERTIES
                INTERFACE_LINK_LIBRARIES "Qt5::RestClientPrivate"
            )
        endif()
    endif()

    _populate_RestClient_target_properties(RELEASE "Qt5RestClient.dll" "libQt5RestClient.a" FALSE)

    if (EXISTS
        "${_qt5RestClient_install_prefix}/bin/Qt5RestClient.dll"
      AND EXISTS
        "${_qt5RestClient_install_prefix}/lib/libQt5RestClient.a" )
        _populate_RestClient_target_properties(DEBUG "Qt5RestClient.dll" "libQt5RestClient.a" FALSE)
    endif()



    # In Qt 5.15 the glob pattern was relaxed to also catch plugins not literally named Plugin.
    # Define QT5_STRICT_PLUGIN_GLOB or ModuleName_STRICT_PLUGIN_GLOB to revert to old behavior.
    if (QT5_STRICT_PLUGIN_GLOB OR Qt5RestClient_STRICT_PLUGIN_GLOB)
        file(GLOB pluginTargets "${CMAKE_CURRENT_LIST_DIR}/Qt5RestClient_*Plugin.cmake")
    else()
        file(GLOB pluginTargets "${CMAKE_CURRENT_LIST_DIR}/Qt5RestClient_*.cmake")
    endif()

    macro(_populate_RestClient_plugin_properties Plugin Configuration PLUGIN_LOCATION
          IsDebugAndRelease)
        set_property(TARGET Qt5::${Plugin} APPEND PROPERTY IMPORTED_CONFIGURATIONS ${Configuration})

        set(imported_location "${_qt5RestClient_install_prefix}/plugins/${PLUGIN_LOCATION}")
        _qt5_RestClient_check_file_exists(${imported_location})
        set_target_properties(Qt5::${Plugin} PROPERTIES
            "IMPORTED_LOCATION_${Configuration}" ${imported_location}
        )

    endmacro()

    if (pluginTargets)
        foreach(pluginTarget ${pluginTargets})
            include(${pluginTarget})
        endforeach()
    endif()



    _qt5_RestClient_check_file_exists("${CMAKE_CURRENT_LIST_DIR}/Qt5RestClientConfigVersion.cmake")
endif()

# Add a versionless target, for compatibility with Qt6.
if(NOT "${QT_NO_CREATE_VERSIONLESS_TARGETS}" AND TARGET Qt5::RestClient AND NOT TARGET Qt::RestClient)
    add_library(Qt::RestClient INTERFACE IMPORTED)
    set_target_properties(Qt::RestClient PROPERTIES
        INTERFACE_LINK_LIBRARIES "Qt5::RestClient"
    )
endif()
