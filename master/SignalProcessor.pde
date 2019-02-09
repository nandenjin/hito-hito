class SignalProcessor {

  int FILTER_LENGTH = 4;
  float[] data = new float[ FILTER_LENGTH ];
  float[] avgs = new float[ FILTER_LENGTH ];

  SignalProcessor() {

  }

  void push( float value ) {

    for( int i = 1; i < FILTER_LENGTH; i++ ) data[ i - 1 ] = data[ i ];
    for( int i = 1; i < FILTER_LENGTH; i++ ) avgs[ i - 1 ] = avgs[ i ];
    data[ FILTER_LENGTH - 1 ] = value;

    float sum = 0;
    for( int i = 0; i < FILTER_LENGTH; i++ ) sum += data[ i ];

    avgs[ FILTER_LENGTH - 1 ] = sum / FILTER_LENGTH;

  }

  float avg() {

    return avgs[ FILTER_LENGTH - 1 ];

  }

  float diff() {

    return ( avgs[ FILTER_LENGTH - 1 ] - avgs[ 0 ] ) / FILTER_LENGTH;

  }

}
