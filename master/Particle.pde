
class Particle {

  Position position = new Position( 0, 0 );
  Position speed = new Position( 1, 1 );
  color col = color( 255, 230, 255 );
  float size = 0;

  float _size = 0;

  void tick() {

    _size += ( size - _size ) / 10;
    position.add( speed );

    size = max( size - 0.3, 0 );

  }

  void render() {

    noStroke();
    fill( col );
    ellipse( position.x, position.y, size, size );

  }

}
