// Action Cable provides the framework to deal with WebSockets in Rails.
// You can generate new channels where WebSocket features live using the `rails generate channel` command.
//
//= require action_cable
//= require_self
//= require_tree ./channels

(function () {
  this.App || (this.App = {}); // App object to hold ActionCable consumer

  App.cable = ActionCable.createConsumer(); // To connect with websocket client

}).call(this); // Self invoking function to avoid polluting global namespace
