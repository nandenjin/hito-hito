
const ws = require( 'ws' );

const server = new ws.Server( { port: 8080 } );

let connections = [];

server.on( 'connection', c => {

  console.log( 'Connection ' + connections.length );
  connections.push( c );

  c.on( 'close', () => connections = connections.filter( t => c !== t ) );
  c.on( 'message', data => {

    console.log( data );

    connections.forEach( d => d.send( data ) );

  } );

} );
