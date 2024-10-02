project('jack_tarea3','cpp',
        default_options : ['cpp_std=c++20', 'buildtype=release'],   
        version : '1.0.0')

# Find PipeWire dependency
jack_dep = dependency('jack')
sndfile_dep = dependency('sndfile')
boost_dep = dependency('boost', modules : ['program_options'])


sources = files('main.cpp', 'jack_client.cpp','passthrough_client.cpp',
                'waitkey.cpp','sndfile_thread.cpp')

executable('tarea3',sources,dependencies:[jack_dep,sndfile_dep,boost_dep])
