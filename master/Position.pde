
class Position {

  float x = 0;
  float y = 0;

  Position( float px, float py ) {

    x = px;
    y = py;

  }

  void set( Position p ) {

    x = p.x;
    y = p.y;

  }

  void setXY( float px, float py ) {

    x = px;
    y = py;

  }

  void add( Position p ) {

    x += p.x;
    y += p.y;

  }

  Position clone() {

    return new Position( x, y );

  }

}
