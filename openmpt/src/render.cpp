#include <iostream>
#include <fstream>
#include <vector>
#include <cpp11.hpp>
#include <libopenmpt/libopenmpt.hpp>
using namespace cpp11;
using namespace openmpt;

#define WAV_HEADER_SIZE 44

module * get_mod(SEXP mod); // specified in get_mod.cpp

static inline uint16_t swapShort ( const uint8_t * const p ) {
  return (uint16_t) ( ( p[0] << 8 ) | p[1] );
}

static inline uint32_t swapLong ( const uint8_t * const p ) {
  return (uint32_t) ( ( swapShort(p) << 16 ) |
          swapShort( p + 2 ) );
}

void mod_write_short(std::ofstream * s, uint16_t val) {
# ifdef WORDS_BIGENDIAN
  val = swapShort((uint8_t *) &val);
# endif
  s->write((char*)(&val), sizeof(uint16_t));
  return;
}

void mod_write_long(std::ofstream * s, uint32_t val) {
# ifdef WORDS_BIGENDIAN
  val = swapLong((uint8_t *) &val);
# endif
  s->write((char*)(&val), sizeof(uint32_t));
  return;
}

[[cpp11::register]]
SEXP render_(SEXP mod, std::string filename, int samplerate, double duration) {
  if (duration <= 0) cpp11::stop("`duration` should have a value greater than zero.");
  double playtime = 0;
  module * my_mod = get_mod(mod);
  std::ofstream tempfile;
  tempfile.open (filename.c_str(), std::ios::out | std::ios::binary);

  // fill header with zero's fill later after writing data
  for (int i = 0; i < WAV_HEADER_SIZE; i ++) {
    tempfile.put('\0');
  }

  constexpr std::size_t buffersize = 480;
  std::vector<int16_t> left( buffersize );
  std::vector<int16_t> right( buffersize );
  
  while(true) {
    std::size_t count = my_mod->read( samplerate, buffersize, left.data(), right.data() );

    for (int i = 0; i < (int)count; i++) {
      mod_write_short(&tempfile, left.at(i));
      mod_write_short(&tempfile, right.at(i));
    }
    
    if (count == 0) break;
    playtime += (double)count/samplerate;
    if (!ISNA(duration) && playtime >= duration) break;
  }
  
  uint32_t file_size = (uint32_t)tempfile.tellp();
  tempfile.seekp(0);
  
  tempfile.write("RIFF", 4);
  mod_write_long(&tempfile, file_size - 8);
  tempfile.write("WAVEfmt ", 8);
  mod_write_long(&tempfile, 16);
  mod_write_short(&tempfile, 1);          // audio format 1 = PCM
  mod_write_short(&tempfile, 2);          // number of channels
  mod_write_long(&tempfile, samplerate);
  mod_write_long(&tempfile, samplerate * 2 * 16 / 8);
  mod_write_short(&tempfile, 2 * 16 / 8); // block align
  mod_write_short(&tempfile, 16);         // bits per sample
  tempfile.write("data", 4);
  mod_write_long(&tempfile, file_size - WAV_HEADER_SIZE); // chunk size

  tempfile.close();
  return R_NilValue;
}
/*
doubles render_(SEXP mod, int n_samples, int sample_rate) {
  module * my_mod = get_mod(mod);
  writable::doubles samps((R_xlen_t)2*n_samples);
  std::vector<float> fl(n_samples);
  std::vector<float> fr(n_samples);
  my_mod->read(sample_rate, n_samples, fl.data(), fr.data());
  for (int i = 0; i < n_samples; i++) {
    samps.at(i*2)     = fl[i]; // left
    samps.at(i*2 + 1) = fr[i]; // right
  }
  return samps;
}
 */
