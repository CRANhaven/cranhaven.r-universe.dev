#include <cpp11.hpp>
#include <vector>
#include <portaudio.h>
using namespace cpp11;

[[cpp11::register]]
bool has_audio_device_(void) {
  int result = 0;
  try {
    Pa_Initialize();
    result = Pa_GetDeviceCount();
    Pa_Terminate();
  } catch(...) {
    
  }
  return result > 0;
}

strings vector_to_strings(std::vector < std::string > v) {
  writable::strings result((R_xlen_t)v.size());
  for (int i = 0; i < (int)v.size(); i++) {
    result.at(i) = r_string(v.at(i));
  }
  return result;
}
