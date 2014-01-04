$(document).ready(function(){
    var showFlashMessage = function ($dom) {
        if ($dom) {
            $dom.fadeOut("slow", function () {
                $dom.remove();
            });
        }
    };
    var removeOnClick = function ($dom) {
        $dom.click(function () {
            $dom.remove();
        });
    };

    var $flashSuccess = $(".flash-success");
    var $flashError   = $(".flash-error");

    setTimeout(function () {
        showFlashMessage($flashSuccess);
        showFlashMessage($flashError);
    }, 2000);

    removeOnClick($flashSuccess);
    removeOnClick($flashError);
});
