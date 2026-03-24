# Naptime — Roadmap for MVP (UI-first)

Этот roadmap переписан так, чтобы ты как можно раньше увидела **живой UI**, но без опасного ухода в «пустые экраны без основы».

Главный принцип:
- сначала делаем **видимый пользовательский сценарий**;
- под каждый экран добавляем **только минимально нужную логику**;
- не строим весь domain/persistence заранее, но и не откладываем критические правила до самого конца.

Такой подход особенно подходит для solo-разработки: он быстрее даёт ощущение прогресса и помогает держать мотивацию.

---

## Как работать по этому roadmap

- Каждую неделю выбирай **один milestone**.
- В `In Progress` держи **одну основную story**.
- Если задача выросла до `XL`, режь её на UI shell / binding / persistence / polish.
- Сначала доводи экран до **демонстрируемого состояния**, потом улучшай детали.
- Для сложных экранов используй порядок: **mock UI → local state → real data → validation/polish**.

---

## Почему UI-first здесь подходит

Для этого продукта это рационально, потому что MVP завязан на очень понятных экранах и коротких действиях:
- Start / Stop sleep
- Today summary
- Session list
- Manual add / edit
- Weekly summary
- Settings

То есть пользовательская ценность хорошо видна через интерфейс уже на раннем этапе.

Но делать **только UI без минимальной логики** я не советую. У Naptime есть правила, которые сильно влияют на архитектуру:
- только одна активная сессия;
- нельзя создавать overlap;
- расчёты зависят от sleep day boundary;
- iPhone остаётся source of truth для MVP.

Если отложить эти вещи слишком поздно, потом придётся переделывать ViewModel, экраны и flows.

Поэтому лучший вариант здесь — **UI-first, но не logic-last**.

---

## Milestone 0 — Project setup + app shell

**Цель недели:** проект открывается, есть базовая навигация и каркас экранов.

### Outcome
- есть Xcode project / workspace
- есть базовая структура папок
- есть табы или навигация для `Today / Sessions / Week / Settings`
- каждый экран открывается с заглушками или mock data
- есть Kanban board со статусами `Backlog / Ready / In Progress / Blocked / Done`

### Recommended stories
- setup проекта и targets
- базовая структура папок
- app shell и navigation
- story 1.1 в минимальном виде, только что нужно для компиляции

### Exit criteria
- приложение компилируется
- можно руками пройти по основным экранам
- после запуска видно, как будет выглядеть структура продукта

### Notes
Это первый milestone, который уже даёт визуальный результат. Не уходи пока в полную data layer.

---

## Milestone 1 — Today screen UI first

**Цель недели:** собрать главный экран iPhone так, чтобы он уже выглядел как продукт.

### Outcome
К концу недели у тебя есть Today screen с реальным layout, даже если часть данных пока на mock/stub state.

### Recommended stories
- UI layout для Today
- большая CTA-кнопка Start / Stop
- active session card
- summary cards
- session list layout
- placeholder / empty state

### Exit criteria
- Today screen визуально собран
- видны состояния: no active session / active session / есть данные за день / пустой день
- экран уже можно показать как первый «кусок приложения»

### Notes
На этом шаге допустимы mock data и fake timer, если это ускоряет прогресс. Но layout нужно строить так, чтобы потом легко подключить реальные данные.

---

## Milestone 2 — First real vertical slice: Start / Stop

**Цель недели:** сделать первый настоящий сценарий MVP через Today screen.

### Outcome
К концу недели кнопка Start / Stop работает по-настоящему, а экран отражает активную сессию.

### Recommended stories
- минимальные модели `SleepSession`
- минимальный repository skeleton
- single active session rule
- start sleep
- stop sleep
- binding Today screen к реальному состоянию

### Exit criteria
- можно стартовать session с iPhone
- можно остановить active session
- на экране видно актуальное running state
- второй active session создать нельзя

### Notes
Вот здесь UI уже перестаёт быть прототипом и становится работающим продуктом.

---

## Milestone 3 — Today becomes trustworthy

**Цель недели:** подключить реальные daily data к Today screen.

### Outcome
К концу недели Today показывает не только кнопку, но и осмысленную дневную картину.

### Recommended stories
- fetch sessions for selected sleep day
- session list binding
- daily summary calculation
- total sleep
- session count
- total awakenings
- empty / loading / partial states

### Exit criteria
- Today screen показывает реальные данные за выбранный sleep day
- список сессий соответствует данным
- total sleep, session count и total awakenings отображаются на экране
- start/stop обновляют экран без ручного refresh

### Notes
На этом шаге уже важно не спорить с PRD: daily view должен показывать total sleep, number of sessions, total awakenings и session list.

---

## Milestone 4 — Manual add flow

**Цель недели:** быстро дать пользователю способ исправить пропущенный трекинг через UI.

### Outcome
К концу недели есть отдельный flow для ручного добавления сессии.

### Recommended stories
- add session screen UI
- date/time inputs
- save action
- базовая validation для диапазона времени
- возврат в Today / Sessions с обновлёнными данными

### Exit criteria
- можно открыть manual add flow
- можно сохранить валидную session
- новая session появляется в списке и влияет на summary
- невалидный диапазон времени не сохраняется

### Notes
Это отличный milestone для ощущения полезности приложения в реальной жизни.

---

## Milestone 5 — Edit / Delete flow

**Цель недели:** сделать sessions действительно редактируемыми через UI.

### Outcome
К концу недели пользователь может исправить ошибочно записанную сессию без боли.

### Recommended stories
- session details / edit screen UI
- редактирование start/end
- delete with confirmation
- refresh Today data после изменений
- понятные validation messages

### Exit criteria
- тап по session открывает edit flow
- можно редактировать session
- можно удалить session с подтверждением
- после edit/delete Today обновляется корректно

### Notes
Если неделя тяжёлая, сначала заверши edit, а delete/polish оставь на конец.

---

## Milestone 6 — Domain correctness hardening

**Цель недели:** укрепить правила, которые уже поддерживают собранный UI.

### Outcome
К концу недели приложение меньше ломается на реальных сценариях.

### Recommended stories
- overlap validation
- sleep day slicing
- recompute daily metrics
- restore active session after relaunch
- unit tests for risky rules

### Exit criteria
- overlap blocked
- active session восстанавливается после relaunch
- расчёты не ломаются на границе sleep day
- есть базовые tests для validation и metrics

### Notes
Это тот milestone, который платит за ранний UI-first. Здесь ты закрываешь архитектурные долги до того, как они станут дорогими.

---

## Milestone 7 — Weekly summary + Settings

**Цель недели:** завершить iPhone MVP и сделать данные интерпретируемыми.

### Outcome
К концу недели есть weekly screen и рабочая настройка sleep day start.

### Recommended stories
- Week screen UI
- weekly aggregation
- calendar week navigation
- Settings screen UI
- sleep day start setting
- recompute summaries after setting change

### Exit criteria
- weekly summary показывает данные по calendar week
- можно смотреть текущую и предыдущие недели
- sleep day start сохраняется
- изменение sleep day start пересчитывает daily и weekly summary

### Notes
Child profile не входит в MVP и не должен быть частью этого milestone.

---

## Milestone 8 — Apple Watch companion

**Цель недели:** добавить быстрый watch-сценарий после того, как iPhone MVP уже стабилен.

### Outcome
К концу недели с часов можно запускать и останавливать трекинг, а базовый state синхронизируется.

### Recommended stories
- watch start / stop UI
- send commands to iPhone
- receive active state
- receive today summary
- simple confirmation feedback

### Exit criteria
- watch может отправить start / stop
- watch показывает active state
- watch получает simple feedback
- iPhone остаётся source of truth

### Notes
Не тащи watch раньше времени. Он очень заметен визуально, но технически добавляет sync-риск.

---

## Optional Milestone 9 — Polish and release prep

**Цель недели:** убрать шероховатости перед TestFlight или первым личным релизом.

### Outcome
К концу недели MVP ощущается собранным и достаточно стабильным.

### Recommended work
- validation copy polish
- empty states
- loading states
- visual cleanup
- smoke test iPhone + Watch
- bugfixes

### Exit criteria
- core flows проверены вручную
- нет известных критических багов
- UI выглядит цельно и предсказуемо

---

## Что считать MVP done

MVP можно считать готовым, когда:
- iPhone позволяет start / stop sleep session
- user can add / edit / delete sessions manually
- Today screen показывает корректные daily данные
- Week screen показывает summary по calendar week
- sleep day start настраивается
- данные сохраняются локально и переживают relaunch
- рискованные доменные правила покрыты базовыми тестами
- если Watch идёт в первый релиз: watch start / stop работает стабильно

---

## Рекомендуемый порядок Kanban при UI-first

1. App shell
2. Today UI
3. Start / Stop vertical slice
4. Today real summary
5. Session list binding
6. Add session
7. Edit / delete session
8. Validation + relaunch recovery
9. Weekly summary
10. Sleep day start
11. Tests
12. Watch
13. Polish

---

## Практическое правило на каждый экран

Для каждого нового экрана проходи 4 шага:
1. собрать layout;
2. подключить local/mock state;
3. подключить real data;
4. добавить validation, edge cases и polish.

Так ты почти всегда будешь видеть визуальный прогресс уже в начале работы, а не только в конце.
