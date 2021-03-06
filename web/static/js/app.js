// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
// import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"

import {Socket} from 'phoenix'

const app = Elm.Main.embed(document.getElementById('app'));
const socket = new Socket('/socket', {});
let channel;

socket.connect();

app.ports.connect.subscribe((username) => {
    channel = socket.channel("chat:lobby", { username });
    channel.join();

    channel.on("shout", app.ports.receive_shout.send);
    channel.on("delete", ({uuid}) =>
        app.ports.receive_delete.send(uuid));
    channel.on("connect", ({username}) =>
        app.ports.receive_connected.send(username));
    channel.on("disconnect", ({username}) =>
        app.ports.receive_disconnected.send(username));
});

app.ports.shout.subscribe(body =>
    channel.push("shout", { body }));

app.ports.delete.subscribe(uuid =>
    channel.push("delete", { uuid }));
