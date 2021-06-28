
%%raw(`import './ServiceBook.css';`)

type lang

type intl

type options = {
  locale: lang 
}

type dt = {
  minutes: int
}

type interval = {
  label: string,
  from: string,
  to: string
}

type expert = {
  name: string,
  picture_url: string,
  schedule: array<interval>
}

type state = 
  | Empty 
  | Loading 
  | Active(ServiceSearch.service, array<interval>)

@module("date-fns") external msToMin: (float) => int = "millisecondsToMinutes"

@module("date-fns") external parse: (string, string, Js.Date.t) => Js.Date.t = "parse"

@module("date-fns") external format: (Js.Date.t, string, options) => string = "format"

@module("date-fns") external duration: (dt, options) => string = "formatDuration"

@module("date-fns") external add: (Js.Date.t, dt) => Js.Date.t = "add"

@module("date-fns") external startMonth: Js.Date.t => Js.Date.t = "startOfMonth"

@module("date-fns") external daysInMonth: Js.Date.t => int = "getDaysInMonth"

@module("date-fns") external dayOfYear: Js.Date.t => int = "getDayOfYear"

@module("date-fns") external addDays: (Js.Date.t, int) => 'a = "addDays"

@module("date-fns") external sunday: Js.Date.t => bool = "isSunday"

@module("date-fns") external monday: Js.Date.t => bool = "isMonday"

@module("date-fns") external tuesday: Js.Date.t => bool = "isTuesday"

@module("date-fns") external wednesday: Js.Date.t => bool = "isWednesday"

@module("date-fns") external thursday: Js.Date.t => bool = "isThursday"

@module("date-fns") external friday: Js.Date.t => bool = "isFriday"

@module("date-fns") external saturday: Js.Date.t => bool = "isSaturday"

@module("date-fns/locale") external es: lang = "es"

@module("firebase/firestore") external firestore: unit => 'a = "getFirestore"

@module("firebase/firestore") external doc: (. 'a, string, string) => 'b = "doc"

@module("firebase/firestore") external get: (. 'b) => Js.Promise.t<'c> = "getDoc"

@scope("Intl") @val external numberFormat: ([#"es-CO" | #"es-MX" | #"en-US"], 'a) => intl = "NumberFormat"

@send external dataService: ('b, 'd) => ServiceSearch.service = "data"

@send external dataUser: ('b, 'd) => expert = "data"

@send external formatCurrency: (intl, float) => string = "format"

@react.component
let make = (~serviceId: string) => {
  let (product, setProduct) = React.useState(_ => Empty) 

  let (date, setDate) = React.useState(_ => Js.Date.make()) 

  let currencySettings = numberFormat(#"es-CO", {
    "style": "currency"
    "currency": "COP"
  })

  let esOptions = {locale: es}

  let month = format(date, "MMMM y", esOptions)

  let start = startMonth(date)

  let startClass = if sunday(start) {
    "Day-sun"
  } else if monday(start) {
    "Day-mon"
  } else if tuesday(start) {
    "Day-tue"
  } else if wednesday(start) {
    "Day-wed"
  } else if thursday(start) {
    "Day-thu"
  } else if friday(start) {
    "Day-fri"
  } else if saturday(start) {
    "Day-sat"
  } else {
    ""
  }

  let dowClass = (d) => {
    let dowStart = d == start ? startClass : ""
    if dayOfYear(d) == dayOfYear(date) && dowStart != "" {
      dowStart ++ " Day-selected"
    } else if dayOfYear(d) == dayOfYear(date) {
      "Day-selected"
    } else {
      dowStart
    }
  }

  let dowP = (l) => if sunday(date) {
    l == "Dom"
  } else if monday(date) {
    l == "Lun"
  } else if tuesday(date) {
    l == "Mar"
  } else if wednesday(date) {
    l == "Mie"
  } else if thursday(date) {
    l == "Jue"
  } else if friday(date) {
    l == "Vie"
  } else if saturday(date) {
    l == "Sab"
  } else {
    false
  }

  let days = Belt.Array.makeByU(daysInMonth(date), (. i) => addDays(start, i))

  let db = firestore()

  React.useEffect0(() => {
    setProduct(_ => Loading)
    Js.Promise.catch((err) => {
      Js.log(err)
      setProduct(_ => Empty)
      Js.Promise.resolve(())
    }, Js.Promise.then_((docSnapshot) => {
      if docSnapshot["exists"] {
        let serverOptions = {
          "serverTimestamps": "none"
        }
        let service = dataService(docSnapshot, serverOptions)
        Js.Promise.then_((docUserSnap) => {
          let schedule = if docUserSnap["exists"] {
            let { schedule } = dataUser(docUserSnap, serverOptions)
            schedule
          } else {
            []
          }
          setProduct(_ => Active(service, schedule))
          Js.Promise.resolve(())
        }, get(. doc(. db, "experts", service.expert.id)))->ignore
      }
      Js.Promise.resolve(())
    }, get(. doc(. db, "services", serviceId))))->ignore 
    None
  })

  <main className="Book">
    <article className="Book-card">
      <aside style={ReactDOM.Style.make(~display="flex", ~flexWrap="wrap", ~alignItems="center", ~justifyContent="space-evenly", ~fontSize=".8em", ~padding="1em", ~maxWidth="calc(30vw - 150px)", ())}>{switch product {
      | Loading => React.string("Loading...")
      | Empty => React.string("Service preview and input data")
      | Active(item, _) => <>
        <img style={ReactDOM.Style.make(~flex="0 1 10%", ~borderRadius="50%", ())} src={item.expert.picture_url} alt="Expert Picture Url" />
        <h3 style={ReactDOM.Style.make(~flex="0 1 10%", ())}>{React.string(item.expert.name)}</h3>
        <p style={ReactDOM.Style.make(~flex="1 1 100%", ())}>{React.string(item.desc)}</p>
        <p style={ReactDOM.Style.make(~flex="1 1 10%", ~fontSize=".8em", ~marginLeft=".5em", ())}>{React.string("Tiempo " ++ duration({ minutes: item.duration }, esOptions))}</p>
        <p style={ReactDOM.Style.make(~flex="1 1 10%", ~fontSize=".8em", ~marginLeft=".5em", ())}>{React.string("Desde " ++ formatCurrency(currencySettings, Belt.Int.toFloat(item.price) /. 100.0))}</p>
      </>
      }}</aside>
      <section className="Calendar">
        <h3 className="Calendar-month">{React.string(Js.String.charAt(0, month)->Js.String.toUpperCase ++ Js.String.sliceToEnd(~from=1, month))}</h3>
        <div className="Calendar-dow">
          <div>{React.string("Dom")}</div>
          <div>{React.string("Lun")}</div>
          <div>{React.string("Mar")}</div>
          <div>{React.string("Mie")}</div>
          <div>{React.string("Jue")}</div>
          <div>{React.string("Vie")}</div>
          <div>{React.string("Sab")}</div>
        </div>
        <div className="Calendar-grid">
          {Belt.Array.map(days, d => <button key={Js.Int.toString(dayOfYear(d))} className={dowClass(d)}><time dateTime={format(d, "y-MM-dd", esOptions)}>{React.string(format(d, "d", esOptions))}</time></button>)->React.array}
        </div>
      </section>
      <aside style={ReactDOM.Style.make(~display="flex", ~flexDirection="column", ~alignItems="center", ~justifyContent="space-around", ~fontSize=".8em", ~padding="1em", ())}>{switch product {
      | Loading => React.string("Loading...")
      | Empty => React.string("Available spots")
      | Active({ duration }, spots) => switch Belt.Array.getBy(spots, ({ label }) => dowP(label)) {
        | None => React.string("Service is not available today")
        | Some(value) => {
          let from = parse(value.from, "H:mm", Js.Date.make())
          let to_ = parse(value.to, "H:mm", Js.Date.make())->Js.Date.getTime->msToMin 
          let slots = (to_ - Js.Date.getTime(from)->msToMin) / duration
          Belt.Array.makeBy(slots, i => <button key={Js.Int.toString(i)} className="Slot"><time dateTime={format(add(from, { minutes: i * duration }), "Pp", esOptions)}>{React.string(format(add(from, { minutes: i * duration }), "h:mm bbb", esOptions))}</time></button>)->React.array
        }
      }
      }}</aside>
      <footer>{React.string("Comfirmation")}</footer>
    </article>
  </main>
}