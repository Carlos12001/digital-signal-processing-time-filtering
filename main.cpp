/**
 * main.cpp
 *
 * Copyright (C) 2023  Pablo Alvarado
 * EL5802 Procesamiento Digital de Señales
 * Escuela de Ingeniería Electrónica
 * Tecnológico de Costa Rica
 *
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * 3. Neither the name of the authors nor the names of its contributors may be
 *    used to endorse or promote products derived from this software without
 *    specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

/** @file main.cpp
 *
 * @brief This is a C++ version of a simple jack client, to serve as
 * a simple framework to test basic digital signal processing algorithms,
 * applied to audio.
 */

#include <boost/program_options.hpp>
#include <csignal>
#include <cstdlib>
#include <filesystem>
#include <iostream>
#include <stdexcept>
#include <vector>

#include "passthrough_client.h"
#include "waitkey.h"

namespace po = boost::program_options;

void signal_handler(int signal) {
  if (signal == SIGINT) {
    std::cout << "Ctrl-C caught, cleaning up and exiting" << std::endl;

    // Let RAII do the clean-up
    exit(EXIT_SUCCESS);
  }
}

int main(int argc, char* argv[]) {
  std::signal(SIGINT, signal_handler);

  try {
    static passthrough_client client;

    po::options_description desc("Allowed options");

    desc.add_options()("help,h", "show usage information")(
        "files,f",
        po::value<std::vector<std::filesystem::path> >()->multitoken(),
        "List of audio files to be played");

    po::variables_map vm;
    po::store(po::parse_command_line(argc, argv, desc), vm);

    if (vm.count("help")) {
      std::cout << desc << std::endl;
      return EXIT_SUCCESS;
    }

    if (client.init() != jack::client_state::Running) {
      throw std::runtime_error("Could not initialize the JACK client");
    }

    if (vm.count("files")) {
      const std::vector<std::filesystem::path>& audio_files =
          vm["files"].as<std::vector<std::filesystem::path> >();

      for (const auto& f : audio_files) {
        bool ok = client.add_file(f);
        std::cout << "Adding file '" << f.c_str() << "' "
                  << (ok ? "succedded" : "failed") << std::endl;
      }
    }

    // keep running until stopped by the user
    std::cout << "Press x key to exit" << std::endl;

    int key = -1;
    bool go_away = false;
    while (!go_away) {
      key = waitkey(100);
      if (key > 0) {
        switch (key) {
          case 'x': {
            go_away = true;
            std::cout << "Finishing..." << std::endl;
          } break;
          case 'r': {
            if (vm.count("files")) {
              const std::vector<std::filesystem::path>& audio_files =
                  vm["files"].as<std::vector<std::filesystem::path> >();

              for (const auto& f : audio_files) {
                bool ok = client.add_file(f);
                std::cout << "  Re-adding file '" << f.c_str() << "' "
                          << (ok ? "succedded" : "failed") << std::endl;
              }
            }

            std::cout << "Repeat playing files" << std::endl;
          } break;
          case 'v': {
            client.reset_volume();
            std::cout << "Volume: " << client.get_volume() << "\n";
            break;
          }
          case '+': {
            client.adjust_volume(0.01);  // Adjust this value as needed.
            std::cout << std::fixed << std::setprecision(2)
                      << "Volume: " << client.get_volume() << "\n"
                      << std::endl;
            break;
          }
          case '-': {
            client.adjust_volume(-0.01);  // Adjust this value as needed.
            std::cout << std::fixed << std::setprecision(2)
                      << "Volume: " << client.get_volume() << "\n"
                      << std::endl;
            break;
          }
          case 'p': {
            client.reset_values_filters();
            client.set_current_mode(passthrough_client::Mode::Passthrough);
            std::cout << "Mode: Passthrough    " << std::endl;
            break;
          }
          case 'l': {
            client.reset_values_filters();
            client.set_current_mode(passthrough_client::Mode::LowPassFilter);
            std::cout << "Mode: LowPassFilter  " << std::endl;
            break;
          }
          case 'm': {
            client.reset_values_filters();
            client.set_current_mode(passthrough_client::Mode::BandStopFilter);
            std::cout << "Mode: BandStopFilter " << std::endl;
            break;
          }
          case 'b': {
            client.reset_values_filters();
            client.set_current_mode(passthrough_client::Mode::BandPassFilter);
            std::cout << "Mode: BandPassFilter " << std::endl;
            break;
          }
          case 'h': {
            client.reset_values_filters();
            client.set_current_mode(passthrough_client::Mode::HighPassFilter);
            std::cout << "Mode: HighPassFilter " << std::endl;
            break;
          }
          default: {
            if (key > 32) {
              std::cout << "Key " << char(key) << " pressed" << std::endl;
            } else {
              std::cout << "Key " << key << " pressed" << std::endl;
            }
            key = -1;
          }
        }  // switch key
      }    // if (key>0)
    }      // end while

    client.stop();
  } catch (std::exception& exc) {
    std::cout << argv[0] << ": Error: " << exc.what() << std::endl;
    exit(EXIT_FAILURE);
  }

  exit(EXIT_SUCCESS);
}
