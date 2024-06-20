"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
var express_1 = __importDefault(require("express"));
var path_1 = __importDefault(require("path"));
var app = (0, express_1.default)();
// index.htmlが存在するディレクトリを指定
var publicDirectoryPath = path_1.default.join(__dirname, '.');
// 静的ファイルを提供するミドルウェアを設定
app.use(express_1.default.static(publicDirectoryPath));
// index.html
app.get("/", function (req, res) {
    res.sendFile(path_1.default.join(publicDirectoryPath, './index.html'));
});
app.listen(3000, function () {
    console.log('ポート3000番で起動');
});
