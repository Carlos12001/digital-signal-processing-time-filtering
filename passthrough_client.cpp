/**
 * passthrough_client.cpp
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

#include "passthrough_client.h"

#include <cstring>

passthrough_client::passthrough_client() : jack::client() {
  current_mode = Mode::Passthrough;
  reset_values_filters();
  reset_volume();
}

passthrough_client::~passthrough_client() {}

/**
 * The process callback for this JACK application is called in a
 * special realtime thread once for each audio cycle.
 *
 * This client does nothing more than copy data from its input
 * port to its output port. It will exit when stopped by
 * the user (e.g. using Ctrl-C on a unix-ish operating system)
 */
bool passthrough_client::process(jack_nframes_t nframes,
                                 const sample_t *const in,
                                 sample_t *const out) {
  switch (current_mode) {
    case Mode::Passthrough:
      passthrough(nframes, in, out);
      break;
    case Mode::LowPassFilter:
      low_pass_filter(nframes, in, out);
      break;
    case Mode::BandStopFilter:
      band_stop_filter(nframes, in, out);
      break;
    case Mode::BandPassFilter:
      band_pass_filter(nframes, in, out);
      break;
    case Mode::HighPassFilter:
      high_pass_filter(nframes, in, out);
      break;
    default:
      passthrough(nframes, in, out);
      break;
  }
  return true;
}

void passthrough_client::passthrough(jack_nframes_t nframes,
                                     const sample_t *const in,
                                     sample_t *const out) {
  for (jack_nframes_t i = 0; i < nframes; ++i) {
    out[i] = in[i] * volume;
  }
}

void passthrough_client::reset_values_filters() {
  x1 = 0.0f;
  x2 = 0.0f;
  y1 = 0.0f;
  y2 = 0.0f;
}

void passthrough_client::adjust_volume(float delta) {
  volume += delta;
  if (volume > 10.0f) volume = 10.0f;
  if (volume < 0.0f) volume = 0.0f;
}

void passthrough_client::low_pass_filter(jack_nframes_t nframes,
                                         const sample_t *const x,
                                         sample_t *const y) {
  for (jack_nframes_t i = 0; i < nframes; i++) {
    y[i] = volume * (-a_lp[1] * y1 - a_lp[2] * y2 + b_lp[0] * x[i] +
                     b_lp[1] * x1 + b_lp[2] * x2);
    x2 = x1;
    x1 = x[i];
    y2 = y1;
    y1 = y[i];
  }
}

void passthrough_client::band_stop_filter(jack_nframes_t nframes,
                                          const sample_t *const x,
                                          sample_t *const y) {
  for (jack_nframes_t i = 0; i < nframes; i++) {
    y[i] = volume * (-a_bs[1] * y1 - a_bs[2] * y2 + b_bs[0] * x[i] +
                     b_bs[1] * x1 + b_bs[2] * x2);
    x2 = x1;
    x1 = x[i];
    y2 = y1;
    y1 = y[i];
  }
}

void passthrough_client::band_pass_filter(jack_nframes_t nframes,
                                          const sample_t *const x,
                                          sample_t *const y) {
  for (jack_nframes_t i = 0; i < nframes; i++) {
    y[i] = volume * (-a_bp[1] * y1 - a_bp[2] * y2 + b_bp[0] * x[i] +
                     b_bp[1] * x1 + b_bp[2] * x2);
    x2 = x1;
    x1 = x[i];
    y2 = y1;
    y1 = y[i];
  }
}

void passthrough_client::high_pass_filter(jack_nframes_t nframes,
                                          const sample_t *const x,
                                          sample_t *const y) {
  for (jack_nframes_t i = 0; i < nframes; i++) {
    y[i] = volume * (-a_hp[1] * y1 - a_hp[2] * y2 + b_hp[0] * x[i] +
                     b_hp[1] * x1 + b_hp[2] * x2);
    x2 = x1;
    x1 = x[i];
    y2 = y1;
    y1 = y[i];
  }
}
