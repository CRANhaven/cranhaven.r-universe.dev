#include <cpp11.hpp>
#include <libopenmpt/libopenmpt.hpp>
using namespace cpp11;
using namespace openmpt;

module * get_mod(SEXP mod); // specified in get_mod.cpp

int render_param_string_to_int(std::string param) {
  int parami;
  if (param.compare("MASTERGAIN") == 0) {
    parami = module::RENDER_MASTERGAIN_MILLIBEL;
  } else if(param.compare("STEREOSEPARATION") == 0) {
    parami = module::RENDER_STEREOSEPARATION_PERCENT;
  } else if(param.compare("INTERPOLATION") == 0) {
    parami = module::RENDER_INTERPOLATIONFILTER_LENGTH;
  } else if(param.compare("VOLUMERAMPING") == 0) {
    parami = module::RENDER_VOLUMERAMPING_STRENGTH;
  } else {
    cpp11::stop("Unknown render parameter");
  }
  return parami;
}

[[cpp11::register]]
int get_render_param_(SEXP mod, std::string param) {
  module * my_mod = get_mod(mod);
  int parami = render_param_string_to_int(param);
  return my_mod->get_render_param(parami);
}

[[cpp11::register]]
SEXP set_render_param_(SEXP mod, std::string param, int value) {
  module * my_mod = get_mod(mod);
  int parami = render_param_string_to_int(param);
  my_mod->set_render_param(parami, value);
  return mod;
}
