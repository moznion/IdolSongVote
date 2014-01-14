# IdolSongVote

For CROSS2014 ぶつかり稽古 ;-)

# Getting Start

    $ carton install
    $ carton exec -- perl scripts/songs_data/init_songs_data.pl
    $ carton exec -- perl scripts/serial_numbers/dispense_serial_numbers.pl 100
    $ carton exec -- plackup

これで動くはず．

`dispense_serial_numbers.pl`の引数に100って与えてますが，もしこれを省略すると100万件シリアルナンバー発行して渋いので気をつけて下さい．

# 使い方

まあ見ればわかると思います．

# ここに至るまでの経緯

Pull-Request見てください．

[https://github.com/moznion/IdolSongVote/pull/1](https://github.com/moznion/IdolSongVote/pull/1)

# LICENSE

MIT
