#include <cpp11.hpp>
#include <libopenmpt/libopenmpt.hpp>
using namespace cpp11;
using namespace openmpt;

module * get_mod(SEXP mod); // specified in get_mod.cpp

[[cpp11::register]]
double get_current_channel_vu_left_(SEXP mod, int channel) {
  module * my_mod = get_mod(mod);
  return my_mod->get_current_channel_vu_left(channel);
}

[[cpp11::register]]
double get_current_channel_vu_mono_(SEXP mod, int channel) {
  module * my_mod = get_mod(mod);
  return my_mod->get_current_channel_vu_mono(channel);
}

[[cpp11::register]]
double get_current_channel_vu_right_(SEXP mod, int channel) {
  module * my_mod = get_mod(mod);
  return my_mod->get_current_channel_vu_right(channel);
}

[[cpp11::register]]
double get_current_channel_vu_rear_left_(SEXP mod, int channel) {
  module * my_mod = get_mod(mod);
  return my_mod->get_current_channel_vu_rear_left(channel);
}

[[cpp11::register]]
double get_current_channel_vu_rear_right_(SEXP mod, int channel) {
  module * my_mod = get_mod(mod);
  return my_mod->get_current_channel_vu_rear_right(channel);
}

[[cpp11::register]]
double get_current_estimated_bpm_(SEXP mod) {
  module * my_mod = get_mod(mod);
  return my_mod->get_current_estimated_bpm();
}

[[cpp11::register]]
int get_current_order_(SEXP mod) {
  module * my_mod = get_mod(mod);
  return my_mod->get_current_order();
}

[[cpp11::register]]
int get_current_pattern_(SEXP mod) {
  module * my_mod = get_mod(mod);
  return my_mod->get_current_pattern();
}

[[cpp11::register]]
int get_current_playing_channels_(SEXP mod) {
  module * my_mod = get_mod(mod);
  return my_mod->get_current_playing_channels();
}

[[cpp11::register]]
int get_current_row_(SEXP mod) {
  module * my_mod = get_mod(mod);
  return my_mod->get_current_row();
}

[[cpp11::register]]
int get_current_speed_(SEXP mod) {
  module * my_mod = get_mod(mod);
  return my_mod->get_current_speed();
}

[[cpp11::register]]
double get_current_tempo_(SEXP mod) {
  module * my_mod = get_mod(mod);
  // In versions >= 0.7.0 get_current_tempo() is deprecated
#if OPENMPT_API_VERSION_MAJOR > 0 || OPENMPT_API_VERSION_MINOR >= 7
  return my_mod->get_current_tempo2();
#else
  return my_mod->get_current_tempo();
#endif
}
