# Naptime — UI-first backlog for MVP

Этот backlog собран на основе `ROADMAP_UI_FIRST.md`.

Принцип:
- сначала делаем **видимый экран или flow**;
- потом подключаем **минимально нужную логику**;
- критичные domain-правила не выносим слишком далеко, чтобы не пришлось переделывать UI.

## Как использовать

Статусы для канбана:
- **Backlog**
- **Ready**
- **In Progress**
- **Blocked**
- **Done**

Рекомендация для solo-режима:
- держать **1 основную задачу** в `In Progress`
- большие задачи `L` и `XL` сразу дробить на UI / binding / persistence / polish

---

## Milestone 0 — Project setup + app shell

### [P0][S] Setup iOS and Watch targets

Что сделать:
- создать iOS target
- создать Watch target
- проверить, что проект собирается
- подготовить минимальные scheme

Готово, когда:
- iOS target собирается
- Watch target собирается
- проект запускается без критических ошибок

Чеклист:
- Есть iOS target
- Есть Watch target
- Проект компилируется
- Scheme доступны и понятны

### [P0][S] Define project folder structure

Что сделать:
- создать папки `Domain`, `Persistence`, `Features`, `Services`, `Shared/UI`
- создать подпапки `Today`, `Sessions`, `Week`, `Settings`
- подготовить место под `WatchConnectivity`
- подготовить место под `TimeProvider`

Готово, когда:
- структура проекта визуально понятна
- новые файлы есть куда класть без хаоса

Чеклист:
- Есть папка `Domain`
- Есть папка `Persistence`
- Есть папка `Features`
- Есть папка `Services`
- Есть папка `Shared/UI` или `Core/UI`
- Есть подпапки `Today / Sessions / Week / Settings`
- Есть место под `WatchConnectivity`
- Есть место под `TimeProvider`

### [P0][S] Create app shell and navigation

Что сделать:
- собрать базовый app shell
- добавить навигацию для `Today / Sessions / Week / Settings`
- сделать заглушки экранов
- настроить стартовый root view

Готово, когда:
- после запуска можно открыть все основные экраны
- структура продукта уже видна визуально

Чеклист:
- Есть root view приложения
- Есть навигация между основными экранами
- Today открывается
- Sessions открывается
- Week открывается
- Settings открывается
- Заглушки не ломают сборку

---

## Milestone 1 — Today screen UI first

### [P0][M] Build Today screen layout

Что сделать:
- собрать layout главного экрана Today
- добавить крупную CTA-кнопку `Start / Stop`
- добавить active session card
- добавить summary cards
- добавить блок session list

Готово, когда:
- экран выглядит как первый реальный экран продукта
- layout не похож на временную техническую заглушку

Чеклист:
- Есть Today header
- Есть CTA `Start / Stop`
- Есть active session card
- Есть summary block
- Есть session list block
- Основной layout адаптирован под пустое и заполненное состояние

### [P0][S] Add Today mock states

Что сделать:
- добавить mock data для Today
- показать состояние без активной сессии
- показать состояние с активной сессией
- показать пустой день
- показать день с данными

Готово, когда:
- Today можно быстро демонстрировать даже без полной data layer

Чеклист:
- Есть state `no active session`
- Есть state `active session`
- Есть empty state
- Есть state с дневными данными
- Переключение между состояниями не требует реального persistence

---

## Milestone 2 — First real vertical slice: Start / Stop

### [P0][S] Define minimal SleepSession model

Что сделать:
- создать минимальную модель `SleepSession`
- покрыть активную и завершённую сессию
- добавить базовые поля `startAt` и `endAt`
- подготовить модель под SwiftData

Готово, когда:
- модель уже пригодна для первого реального start/stop сценария

Чеклист:
- Есть модель `SleepSession`
- Модель поддерживает active session
- Модель поддерживает completed session
- Поля согласованы с PRD и TECH_SPEC

### [P0][M] Create minimal repository skeleton

Что сделать:
- определить минимальный repository contract
- добавить операции для active session
- добавить сохранение и чтение сессий
- подключить SwiftData skeleton

Готово, когда:
- Today screen можно привязать к реальному состоянию

Чеклист:
- Есть repository interface или service contract
- Есть создание session
- Есть завершение active session
- Есть получение active session
- Есть базовый SwiftData path

### [P0][M] Implement Start / Stop flow on Today

Что сделать:
- привязать кнопку `Start / Stop` к реальному состоянию
- создать start flow
- создать stop flow
- показать running state на экране
- заблокировать вторую active session

Готово, когда:
- первый настоящий сценарий MVP работает через Today

Чеклист:
- Можно стартовать sleep session с iPhone
- Можно остановить active session
- Экран показывает актуальное running state
- Вторую active session создать нельзя
- После действий UI обновляется без ручного refresh

---

## Milestone 3 — Today becomes trustworthy

### [P0][M] Bind Today session list to real data

Что сделать:
- получать session list для выбранного sleep day
- подключить список к реальным данным
- корректно отображать active и completed sessions
- обновлять список после start/stop

Готово, когда:
- список на Today отражает реальное состояние данных

Чеклист:
- Today показывает реальные sessions
- Active session отображается корректно
- Completed sessions отображаются корректно
- После start/stop список обновляется

### [P0][M] Calculate and show daily summary

Что сделать:
- посчитать `total sleep`
- посчитать `session count`
- посчитать `total awakenings`
- показать daily summary на Today
- обновлять summary после изменений данных

Готово, когда:
- Today показывает полезную дневную картину, а не только кнопку

Чеклист:
- Показывается `total sleep`
- Показывается `session count`
- Показывается `total awakenings`
- Значения обновляются после start/stop
- Значения соответствуют данным списка

### [P0][S] Add Today loading and empty states

Что сделать:
- добавить empty state для дня без данных
- добавить loading state, если нужен
- продумать partial state для переходных случаев
- не ломать layout при отсутствии данных

Готово, когда:
- экран остаётся понятным в неполных состояниях

Чеклист:
- Есть empty state
- Есть loading state или его эквивалент
- Нет визуальных поломок при пустых данных
- Today остаётся читаемым во всех основных состояниях

---

## Milestone 4 — Manual add flow

### [P0][M] Build manual add screen

Что сделать:
- собрать экран ручного добавления сессии
- добавить выбор даты и времени начала
- добавить выбор даты и времени окончания
- добавить кнопку сохранения
- вернуть пользователя в основной flow после сохранения

Готово, когда:
- manual add flow полностью проходит через UI

Чеклист:
- Экран manual add открывается
- Можно ввести start time
- Можно ввести end time
- Есть save action
- После сохранения пользователь возвращается в приложение без тупика

### [P0][S] Validate manual add input

Что сделать:
- проверить, что `endAt > startAt`
- не сохранять невалидный диапазон времени
- показать понятные validation messages
- обновить Today после успешного сохранения

Готово, когда:
- ручное добавление не создаёт очевидно некорректные данные

Чеклист:
- Невалидный диапазон времени блокируется
- Показывается понятная ошибка
- Валидная session сохраняется
- Новая session влияет на summary и список

---

## Milestone 5 — Edit / Delete flow

### [P0][M] Build edit session flow

Что сделать:
- открыть existing session на редактирование
- дать менять `startAt` и `endAt`
- сохранить изменения
- обновить Today после редактирования

Готово, когда:
- пользователь может исправить неверно записанную сессию

Чеклист:
- Тап по session открывает edit flow
- Можно изменить `startAt`
- Можно изменить `endAt`
- Изменения сохраняются
- Today обновляется после edit

### [P0][S] Delete session with confirmation

Что сделать:
- добавить delete action
- добавить confirmation step
- обновить summary и список после удаления
- не оставлять пользователя без обратной связи

Готово, когда:
- удаление безопасно и предсказуемо

Чеклист:
- Есть delete action
- Есть confirmation
- Session удаляется только после подтверждения
- Today summary обновляется после delete
- Session исчезает из списка после delete

---

## Milestone 6 — Domain correctness hardening

### [P0][M] Add overlap validation and single-active protection

Что сделать:
- запретить overlap между session
- укрепить правило одной active session
- корректно обработать редактирование existing session
- показать понятные ошибки при конфликте

Готово, когда:
- приложение не даёт создать конфликтующие данные

Чеклист:
- Overlap blocked при add
- Overlap blocked при edit
- Вторая active session не создаётся
- Ошибки понятны пользователю

### [P0][M] Implement sleep day slicing and reliable metrics

Что сделать:
- нарезать session по границам sleep day
- пересчитывать daily metrics по пересечению с day window
- проверить кейсы на границе day start
- подготовить weekly aggregation на той же основе

Готово, когда:
- daily totals остаются корректными даже на границах sleep day

Чеклист:
- Session crossing boundary считается корректно
- Daily total корректен
- Session count корректен
- Total awakenings корректен
- Расчёты не ломаются при изменении sleep day start

### [P0][S] Restore active session after relaunch

Что сделать:
- восстановить active session после relaunch
- показать корректный running state после повторного открытия приложения
- не создавать дубликаты active session

Готово, когда:
- live tracking переживает relaunch без потери доверия

Чеклист:
- Active session восстанавливается после relaunch
- UI показывает корректный running state
- Start/Stop после relaunch работает корректно
- Нет duplicate active state

### [P0][S] Add unit tests for risky domain rules

Что сделать:
- покрыть тестами overlap detection
- покрыть тестами sleep day slicing
- покрыть тестами daily metrics
- покрыть тестами single-active invariant

Готово, когда:
- самые рискованные правила защищены базовыми тестами

Чеклист:
- Есть tests на overlap
- Есть tests на day slicing
- Есть tests на daily metrics
- Есть tests на active session invariant

---

## Milestone 7 — Weekly summary + Settings

### [P1][M] Build Week screen and weekly aggregation

Что сделать:
- собрать Week screen UI
- показать данные по calendar week
- посчитать weekly average total sleep
- обновлять экран после изменений session

Готово, когда:
- weekly screen уже полезен как часть MVP

Чеклист:
- Есть Week screen UI
- Показаны данные по calendar week
- Показан weekly average total sleep
- Значения обновляются после add/edit/delete

### [P1][S] Add calendar week navigation

Что сделать:
- дать смотреть текущую неделю
- дать смотреть предыдущие недели
- сделать понятное переключение между calendar weeks

Готово, когда:
- пользователь может просматривать историю по неделям

Чеклист:
- Открывается текущая week
- Можно перейти к previous week
- Навигация по неделям понятна
- Данные не сваливаются в режим “последние 7 дней”

### [P1][S] Build Settings screen for sleep day start

Что сделать:
- собрать Settings screen UI
- добавить настройку `sleep day start`
- сохранить значение локально
- пересчитать daily и weekly summary после изменения

Готово, когда:
- пользователь может менять day boundary без ручной правки данных

Чеклист:
- Есть Settings screen UI
- Можно выбрать `sleep day start`
- Значение сохраняется локально
- Daily summary пересчитывается после изменения
- Weekly summary пересчитывается после изменения

---

## Milestone 8 — Apple Watch companion

### [P1][M] Build Watch start / stop UI

Что сделать:
- собрать минимальный watch UI
- показать текущий active state
- добавить start action
- добавить stop action
- добавить простую feedback-индикацию

Готово, когда:
- watch позволяет выполнить базовый трекинг-сценарий

Чеклист:
- Watch показывает active state
- Есть start action
- Есть stop action
- Есть базовая confirmation/error feedback

### [P1][M] Implement Watch sync state

Что сделать:
- отправлять команды с watch на iPhone
- получать state c iPhone на watch
- синхронизировать today summary
- сохранить iPhone как source of truth

Готово, когда:
- watch работает как companion, а не как отдельный источник данных

Чеклист:
- Watch отправляет start command
- Watch отправляет stop command
- Watch получает current active state
- Watch получает today's total
- Watch получает session count
- iPhone остаётся source of truth

---

## Milestone 9 — Polish and release prep

### [P1][M] Polish core flows and prepare release candidate

Что сделать:
- улучшить validation copy
- подчистить empty и loading states
- убрать визуальные шероховатости
- сделать smoke test на iPhone и Watch
- закрыть критичные баги

Готово, когда:
- MVP выглядит цельно и предсказуемо
- основные сценарии проверены вручную

Чеклист:
- Валидационные сообщения понятны
- Empty states выглядят аккуратно
- Основные экраны выглядят согласованно
- Core flows проверены вручную
- Нет известных критичных багов

---

## MVP done checklist

MVP можно считать готовым, когда:
- iPhone позволяет `start / stop` sleep session
- user can add / edit / delete sessions manually
- Today screen показывает корректные daily данные
- Week screen показывает summary по **calendar week**
- `sleep day start` настраивается
- данные сохраняются локально и переживают relaunch
- рискованные domain-правила покрыты базовыми tests
- если Watch входит в первый релиз: watch start / stop работает стабильно
