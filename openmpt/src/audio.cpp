#include <cpp11.hpp>
#include <libopenmpt/libopenmpt.hpp>
#include <portaudiocpp/PortAudioCpp.hxx>
using namespace cpp11;
using namespace openmpt;

#define MAX_VU_METER 20

module * get_mod(SEXP mod); // specified in get_mod.cpp

void pl_progress_report(module * mod, std::string * progress, uint32_t * counter, float * vu) {
  uint32_t stepsize = 5;
  uint32_t n_channels = mod->get_num_channels();
  float delta = 0;
  for (uint32_t i = 0; i < n_channels; i++) {
    float temp = mod->get_current_channel_vu_mono(i)/1.414214;
    delta += temp*temp;
  }
  *vu += std::sqrt(delta) / std::sqrt(n_channels);
  if (progress->compare("none") == 0 || *counter % stepsize != 0) {
    return;

  } else if (progress->compare("vu") == 0) {

    uint8_t vu_meter = MAX_VU_METER * *vu/ stepsize;
    std::string vu_meter_s = "\r";
    for (uint8_t j = 0; j < MAX_VU_METER; j++) {
      if (j < vu_meter) {
        vu_meter_s.append("\u25A0");
      } else {
        vu_meter_s.append(" ");
      }
    }
    Rprintf("%s", vu_meter_s.c_str());
    *vu = 0;

  } else if (progress->compare("time") == 0) {

    float secs = mod->get_position_seconds();
    float total = mod->get_duration_seconds();
    Rprintf("\r%02i:%02i (%02i:%02i)",
            ((int)(secs/60))%60,  ((int)secs)%60,
            ((int)(total/60))%60,  ((int)total)%60);
  }
  return;
}

[[cpp11::register]]
SEXP test_omt_progress(SEXP mod, std::string progress) {
  module * my_mod = get_mod(mod);
  uint32_t counter = 0;
  float vu = 0;
  pl_progress_report(my_mod, & progress, & counter, & vu);
  return R_NilValue;
}

[[cpp11::register]]
SEXP play_(SEXP mod, int samplerate, std::string progress, double duration) {
  module * my_mod = get_mod(mod);
  if (duration <= 0) cpp11::stop("`duration` should have a value greater than zero.");
  double playtime = 0;
  try {
    constexpr std::size_t buffersize = 480;
    portaudio::AutoSystem portaudio_initializer;
    portaudio::System & portaudio = portaudio::System::instance();
    std::vector<float> left( buffersize );
    std::vector<float> right( buffersize );
    std::vector<float> interleaved_buffer( buffersize * 2 );
    bool is_interleaved = false;
#if defined( _MSC_VER ) && defined( _PREFAST_ )
    // work-around bug in VS2019 MSVC 16.5.5 static analyzer
    is_interleaved = false;
    portaudio::DirectionSpecificStreamParameters outputstream_parameters( portaudio.defaultOutputDevice(), 2, portaudio::FLOAT32, false, portaudio.defaultOutputDevice().defaultHighOutputLatency(), 0 );
    portaudio::StreamParameters stream_parameters( portaudio::DirectionSpecificStreamParameters::null(), outputstream_parameters, samplerate, paFramesPerBufferUnspecified, paNoFlag );
    portaudio::BlockingStream stream( stream_parameters );
#else
    portaudio::BlockingStream stream = [&]()
    {
      try {
        is_interleaved = false;
        portaudio::DirectionSpecificStreamParameters outputstream_parameters( portaudio.defaultOutputDevice(), 2, portaudio::FLOAT32, false, portaudio.defaultOutputDevice().defaultHighOutputLatency(), 0 );
        portaudio::StreamParameters stream_parameters( portaudio::DirectionSpecificStreamParameters::null(), outputstream_parameters, samplerate, paFramesPerBufferUnspecified, paNoFlag );
        return portaudio::BlockingStream( stream_parameters );
      } catch ( const portaudio::PaException & e ) {
        if ( e.paError() != paSampleFormatNotSupported ) {
          throw;
        }
        is_interleaved = true;
        portaudio::DirectionSpecificStreamParameters outputstream_parameters( portaudio.defaultOutputDevice(), 2, portaudio::FLOAT32, true, portaudio.defaultOutputDevice().defaultHighOutputLatency(), 0 );
        portaudio::StreamParameters stream_parameters( portaudio::DirectionSpecificStreamParameters::null(), outputstream_parameters, samplerate, paFramesPerBufferUnspecified, paNoFlag );
        return portaudio::BlockingStream( stream_parameters );
      }
    }();
#endif
    stream.start();
    uint32_t counter = 0;
    float vu = 0;
    if (progress.compare("none") != 0)
      Rprintf("Press [Esc] to pause\n");
    while ( true ) {
      pl_progress_report(my_mod, &progress, &counter, &vu);
      counter++;
      R_CheckUserInterrupt();
      std::size_t count = is_interleaved ? my_mod->read_interleaved_stereo( samplerate, buffersize, interleaved_buffer.data() ) : my_mod->read( samplerate, buffersize, left.data(), right.data() );
      if ( count == 0 ) {
        break;
      }
      try {
        if ( is_interleaved ) {
          stream.write( interleaved_buffer.data(), static_cast<unsigned long>( count ) );
        } else {
          const float * const buffers[2] = { left.data(), right.data() };
          stream.write( buffers, static_cast<unsigned long>( count ) );
        }
      } catch ( const portaudio::PaException & pa_exception ) {
        if ( pa_exception.paError() != paOutputUnderflowed ) {
          throw;
        }
      }
      playtime += (double)count/samplerate;
      if (!ISNA(duration) && playtime >= duration) break;
    }
    stream.stop();
  } catch ( const std::bad_alloc & ) {
    cpp11::stop("Out of memory");
  } catch ( const std::exception & e ) {
    cpp11::stop("Error %s", std::string( e.what() ? e.what() : "unknown error" ).c_str());
  }
  return R_NilValue;
}
