var client = require('cheerio-httpcli');
var fs = require('fs');

client.fetch('https://news.tbs.co.jp/', function (err, $, res, body) {
  // リンク一覧を取得
  $('section.md-headline div.gr-row-wrap a').each(function (idx) {
    var path = $(this).attr('href');
    var dir = /(\d+)\.html/.exec(path)[1];
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir);
      client.fetch('https://news.tbs.co.jp/' + path, function (err, $, res, body) {
        // HTMLタイトルを表示
        var text = "";
        $("#mainContent > div.ls-inner p").each(function (idx) {
          text += $(this).text() + "\n";
        });
        fs.writeFile(dir + "/" + dir + ".txt", text, function(err) {
          if (err) throw err;
          console.log(dir);
        });
      })
    }
 });
});
