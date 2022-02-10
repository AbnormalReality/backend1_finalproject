Описание и принцип работы  программы - Сокращатель ссылок.

Программа использует файловое хранилище в формате json

fields and json record structure:

"data": [
{
"uid": “string” - идентификатор пользователя (уникальный ключ)
"url": "string", - исходная ссылка
"shorturl" : "string", - короткая ссылка, генерируемая (как уникальный ключ)
"datetime": "2021-05-31T00:15:11.177Z", - дата создания изменения
"active": 1 - активная ссылка (0- удалена)
"redirs": 0 – сч-ик переходов по ссылке
},
]

structure which represents json format:

type Data []struct {
UID string json:"uid"
URL string json:"url"
Shorturl string json:"shorturl"
Datetime time.Time json:"datetime"
Active int json:"active"
Redirs int json:"redirs"
}

Апи.
Реализован метод crud для хранения записей, методы для аутентификации: - выдача пары jwt token,
метод открытия короткой ссылки и редиректа на URL. Подробнее можно ознакомиться с ним в Свагере. (в папке swagger) – конфиг YAML с описанием всех апи методов и структур. Ошибки.

Для работы с программой, первое что нужно сделать - пройти аутентификацию и получить ключи для авторизации.

curl -X POST http://127.0.0.1:8000/user/auth -H "Content-Type: application/json" -d '{"uid":"any user"}'

в ответ придут пара ключей,
{"accessToken":"eyJhbG...","refreshToken":"sdsdsd....."}

accessToken ключ нужно использовать для доступа к апи, указывая его всякий раз при обращении к методам апи, например:

curl -X GET http://127.0.0.1:8000/links/all -H "Authorization: Bearer eyJhbGciOiJIUzI1NiI...токен...."

-должен выдать список линков этого пользователя "any user",

но если происходит ошибка авторизации может прийти такое сообщение:

{"errors":[{"code":1,"message":"Token has expired time"}]}


Принцип работы файло-хранилища.

// FileRepo - структура для файло-стораджа
type FileRepo struct {
sync.RWMutex
fileName string
fileData map[string]model.DataEl
}

Апи работает с этой структурой через интерфейс, FileRepo хранит мапу fileData, ключем которой является пара “uid:shorturl” а значением элемент файла-json-структуры (представленной в начале). Сам физический файл (storage.json) создается на диске и апдейтится, при любом изменении этой мапы (при удалении элемента, меняется флаг active=0 и на диск такие записи не скидываются).

Работа с хранилищем осуществляется через интерфейс:

type linkSvc interface {
Get(uid, key string) (model.DataEl, error)
Put(uid, key string, value model.DataEl) error
Del(uid, key string) error
List(uid string) ([]string, error)
GetUn(shortlink string) (model.DataEl, error)
}

Первые 3 метода реализуют стандартный доступ типа crud, но, нужно задавать uid для указания конкретного пользователя. Метод list служит для того, чтобы, где необходимо, получить список всех ссылок конкретного пользователя. Метод GetUn – выполняет поиск уникальной короткой ссылки во всем хранилище (без указания пользователя) и увеличивает (в режиме лока структуры) счетчик redir +1. Этот метод служит для открывания короткой ссылки и перехода redir по URL.

Для работы с API был также написан клиент на node js. Файлы находятся в папке nodejs/proj1 Запуск из этой папки командой: node server.js Заход: http://127.0.0.1:8090/

erver node.js started http://127.0.0.1:8090 (API URL: https://web-link19801.herokuapp.com )

#posgres migrations make: (dir called migrations)
-- go get -tags 'postgres' -u github.com/golang-migrate/migrate/cmd/migrate or brew install golang-migrate (mac)
-- migrate create -seq -ext sql -dir migrations init_schema
-- clean db eg 'a5' must exist: psql -h localhost -U postgres -w -c "create database a5;"

use:
init: migrate -database "postgres://postuser:password@192.168.1.204:5432/a5?sslmode=disable" -path migrations up (put your creds)
rollback: migrate -database "postgres://postuser:password@192.168.1.204:5432/a5?sslmode=disable" -path migrations down
