
int BLINK_CYCLE = 2000;

class Particle {

  Position position = new Position( 0, 0 );
  Position speed = new Position( 1, 1 );
  color col = color( 255, 230, 255 );
  float size = 0;
  float decay = 0.3;
  float blinkOffset = 0;

  float _size = 0;

  void tick() {

    _size += ( size - _size ) / 10;
    position.add( speed );

  }

  void render() {

    noStroke();
    float opacity = ( sin( (float)millis() / BLINK_CYCLE * PI + blinkOffset ) + 1 ) / 2;
    fill( color( hue( col ), saturation( col ), brightness( col ), ( opacity ) * 100 ) );
    ellipse( position.x, position.y, _size, _size );

  }

}
