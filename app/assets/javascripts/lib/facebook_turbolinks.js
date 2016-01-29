/*
Copyright 2013 Neighbor Market

This file is part of Neighbor Market.

Neighbor Market is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Neighbor Market is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Neighbor Market.  If not, see <http://www.gnu.org/licenses/>.
*/

(function($, window) {

	$(function() {
		loadFacebookSDK();
		if (!window.fbEventsBound) {
			return bindFacebookEvents();
		}
	})

	function bindFacebookEvents() {
	  $(document).on('page:fetch', saveFacebookRoot).on('page:change', restoreFacebookRoot).on('page:load', function() {
	    return typeof FB !== "undefined" && FB !== null ? FB.XFBML.parse() : void 0;
	  });
	  return this.fbEventsBound = true;
	};

	saveFacebookRoot = function() {
	  if ($('#fb-root').length) {
	    return this.fbRoot = $('#fb-root').detach();
	  }
	};

	function restoreFacebookRoot() {
	  if (this.fbRoot != null) {
	    if ($('#fb-root').length) {
	      return $('#fb-root').replaceWith(this.fbRoot);
	    } else {
	      return $('body').append(this.fbRoot);
	    }
	  }
	};

	function loadFacebookSDK() {
	  window.fbAsyncInit = initializeFacebookSDK;
	  return $.getScript("//connect.facebook.net/en_US/sdk.js");
	};

	function initializeFacebookSDK() {
	  return FB.init({
	    appId: window.FB_APPID,
	    version: 'v2.5',
	    xfbml: true
	  });
	};

})(jQuery, window);