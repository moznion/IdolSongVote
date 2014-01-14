var page      = require('webpage').create();
var url       = 'http://ja.wikipedia.org/wiki/%E6%9B%B2%E5%90%8D%E4%B8%80%E8%A6%A7';
var jqueryLib = 'http://code.jquery.com/jquery-1.10.2.min.js';

page.open(url, function (status) {
    page.includeJs(jqueryLib, function () {
        var songsListStr = page.evaluate(function () {
            var alphanuumericRegex = /^\w/;
            var songsListStr = '';
            $('h3', $('#bodyContent')).each(function () {
                var headline = $('span.mw-headline', this).text();
                if (headline.length > 1) {
                    next;
                }

                var list = $(this).next();
                var i = 1;
                $('li', $(list)).each(function () {
                    var songTitle = $(this).text();

                    var firstCharacter = headline;
                    if (songTitle.match(alphanuumericRegex)) {
                        firstCharacter = songTitle.charAt(0).toUpperCase();
                    }

                    songsListStr += 'title:' + songTitle + "\tinitial:" + firstCharacter + "\n";

                    if (i > 15) {
                        return false;
                    }
                    i++;
                });
            });
            return songsListStr;
        });
        console.log(songsListStr);
        phantom.exit();
    });
});
