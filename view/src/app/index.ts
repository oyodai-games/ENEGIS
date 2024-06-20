import express from 'express'
import path from 'path';
const app: express.Express = express()


// index.htmlが存在するディレクトリを指定
const publicDirectoryPath = path.join(__dirname, '.');

// 静的ファイルを提供するミドルウェアを設定
app.use(express.static(publicDirectoryPath));

// index.html
app.get("/", (req, res) => {
    res.sendFile(path.join(publicDirectoryPath, './index.html'));
});


app.listen(3000,()=>{
    console.log('ポート3000番で起動')
})
