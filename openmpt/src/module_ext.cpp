#include <cpp11.hpp>
#include <libopenmpt/libopenmpt.hpp>
#include <libopenmpt/libopenmpt_ext.hpp>
using namespace cpp11;
using namespace openmpt;

module * get_mod(SEXP mod); // specified in get_mod.cpp

ext::interactive * get_interactive(SEXP mod) {
  module_ext * my_mod = (module_ext *)get_mod(mod);
  ext::interactive * iact = nullptr;
#ifdef LIBOPENMPT_EXT_INTERFACE_INTERACTIVE
  iact =
    static_cast<ext::interactive *>(my_mod->get_interface(ext::interactive_id));
  if (!iact) {
    cpp11::stop("Failed to get libopenmpt interactive object");
  }
#else
  cpp11::stop("libopenmpt interactive mode not available");
#endif
  return iact;
}

[[cpp11::register]]
SEXP set_channel_mute_status_(SEXP mod, int channel, bool status) {
  ext::interactive * iact = get_interactive(mod);
  iact->set_channel_mute_status(channel, status);
  return mod;
}

[[cpp11::register]]
bool get_channel_mute_status_(SEXP mod, int channel) {
  ext::interactive * iact = get_interactive(mod);
  return iact->get_channel_mute_status(channel);
}

[[cpp11::register]]
SEXP set_global_volume_(SEXP mod, double volume) {
  ext::interactive * iact = get_interactive(mod);
  iact->set_global_volume(volume);
  return mod;
}

[[cpp11::register]]
double get_global_volume_(SEXP mod) {
  ext::interactive * iact = get_interactive(mod);
  return iact->get_global_volume();
}

[[cpp11::register]]
SEXP set_channel_volume_(SEXP mod, int channel, double volume) {
  ext::interactive * iact = get_interactive(mod);
  iact->set_channel_volume(channel, volume);
  return mod;
}

[[cpp11::register]]
double get_channel_volume_(SEXP mod, int channel) {
  ext::interactive * iact = get_interactive(mod);
  return iact->get_channel_volume(channel);
}

[[cpp11::register]]
SEXP set_pitch_factor_(SEXP mod, double factor) {
  ext::interactive * iact = get_interactive(mod);
  iact->set_pitch_factor(factor);
  return mod;
}

[[cpp11::register]]
double get_pitch_factor_(SEXP mod) {
  ext::interactive * iact = get_interactive(mod);
  return iact->get_pitch_factor();
}

[[cpp11::register]]
SEXP set_tempo_factor_(SEXP mod, double factor) {
  ext::interactive * iact = get_interactive(mod);
  iact->set_tempo_factor(factor);
  return mod;
}

[[cpp11::register]]
double get_tempo_factor_(SEXP mod) {
  ext::interactive * iact = get_interactive(mod);
  return iact->get_tempo_factor();
}
