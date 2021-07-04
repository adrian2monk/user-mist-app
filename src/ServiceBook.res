@module("./success.svg") external success: string = "default"

%%raw(`import './ServiceBook.css';`)

type lang

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

type client = {
  name: string,
  email: string
}

type booking = {
  state: string,
  service: string,
  expert: ServiceSearch.user,
  client: client,
  comment: string,
  date: Js.Date.t,
  time_to: string,
  time_from: string,
}

type state = 
  | Empty 
  | Booked 
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

@module("date-fns") external eq: (Js.Date.t, Js.Date.t) => bool = "isEqual"

@module("date-fns/locale") external es: lang = "es"

@module("firebase/firestore") external firestore: unit => 'a = "getFirestore"

@module("firebase/firestore") external collection: (. 'a, string) => 'b = "collection"

@module("firebase/firestore") external doc: (. 'a, string, string) => 'b = "doc"

@module("firebase/firestore") external ref: (. 'b) => 'c = "doc"

@module("firebase/firestore") external get: (. 'b) => Js.Promise.t<'c> = "getDoc"

@module("firebase/firestore") external set: (. 'b, booking) => Js.Promise.t<'c> = "setDoc"

@send external dataService: ('b, 'd) => ServiceSearch.service = "data"

@send external dataUser: ('b, 'd) => expert = "data"

let esOptions = {locale: es}

let esFormatDate = (d, f) => format(d, f, esOptions)

module ServiceForm = {
  @react.component
  let make = (~date: Js.Date.t, ~isBooked: bool, ~item: ServiceSearch.service, ~onBook) => {

    let (name, setName) = React.useState(_ => "") 

    let (email, setEmail) = React.useState(_ => "") 

    let (comment, setComment) = React.useState(_ => "") 

    let getValue = (e) => {
      let t = ReactEvent.Form.target(e)
      t["value"]
    }

    let onClick = (e) => {
      ReactEvent.Mouse.preventDefault(e) 
      onBook({
        date,
        comment,
        client: {
          name,
          email
        },
        time_from: esFormatDate(date, "H:mm"),
        time_to: esFormatDate(add(date, { minutes: item.duration }), "H:mm"),
        expert: item.expert,
        service: item.id,
        state: "PENDING"
      })
    }

    <form className="Book-confirmation">
      <label>{React.string("Nombre")}</label>
      <input id="name" type_="text" value={name} onChange={e => setName(_ => getValue(e))} />
      <label>{React.string("Email")}</label>
      <input id="email" type_="email" value={email} onChange={e => setEmail(_ => getValue(e))} />
      <label>{React.string("Comentarios")}</label>
      <textarea id="comment" rows=5 cols=30 value={comment} onChange={e => setComment(_ => getValue(e))}></textarea>
      <button className="Book-primary" disabled={!isBooked} onClick>{React.string("Solicitar cita")}</button>
    </form>
  }
}

module ServiceCalendar = {
  @react.component
  let make = (~date: Js.Date.t, ~onSelect) => {

    let month = esFormatDate(date, "MMMM y")

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

    let days = Belt.Array.makeByU(daysInMonth(date), (. i) => addDays(start, i))

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
        {Belt.Array.map(days, d => <button key={Js.Int.toString(dayOfYear(d))} className={dowClass(d)} onClick={(_) => onSelect(d)}><time dateTime={esFormatDate(d, "y-MM-dd")}>{React.string(esFormatDate(d, "d"))}</time></button>)->React.array}
      </div>
    </section>
  }
}

module ServiceSlots = {
  @react.component
  let make = (~date: Js.Date.t, ~duration: int, ~spots: array<interval>, ~onSelect) => {

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

    switch Belt.Array.getBy(spots, ({ label }) => dowP(label)) {
    | None => React.string("Service is not available today")
    | Some(value) => {
      let from = parse(value.from, "H:mm", date)
      let to_ = parse(value.to, "H:mm", date)->Js.Date.getTime->msToMin 
      let slots = (to_ - Js.Date.getTime(from)->msToMin) / duration
      let timeFrom = (i) => add(from, { minutes: i * duration })
      let esFormatSlot = (i, f) => esFormatDate(timeFrom(i), f)
      Belt.Array.makeBy(slots, i => <button key={Js.Int.toString(i)} className={"Slot" ++ (eq(date, timeFrom(i)) ? " Slot-selected" : "")} onClick={(_) => onSelect(timeFrom(i))}><time dateTime={esFormatSlot(i, "Pp")}>{React.string(esFormatSlot(i, "h:mm bbb"))}</time></button>)->React.array
    }}
  }
}

module ServicePreview = {
  @react.component
  let make = (~item: ServiceSearch.service) => {
    <>
      <img style={ReactDOM.Style.make(~flex="0 1 10%", ~borderRadius="50%", ())} src={item.expert.picture_url} alt="Expert Picture Url" />
      <h3 style={ReactDOM.Style.make(~flex="0 1 10%", ())}>{React.string(item.expert.name)}</h3>
      <p style={ReactDOM.Style.make(~flex="1 1 100%", ())}>{React.string(item.desc)}</p>
      <p style={ReactDOM.Style.make(~flex="1 1 10%", ~fontSize=".8em", ~marginLeft=".5em", ())}>{React.string("Tiempo " ++ duration({ minutes: item.duration }, esOptions))}</p>
      <p style={ReactDOM.Style.make(~flex="1 1 10%", ~fontSize=".8em", ~marginLeft=".5em", ())}>{React.string("Desde " ++ ServiceSearch.currency(Belt.Int.toFloat(item.price) /. 100.0))}</p>
    </>
  }
}

@react.component
let make = (~serviceId: string) => {
  let (product, setProduct) = React.useState(_ => Empty) 

  let (isBooked, setBooked) = React.useState(_ => false) 

  let (date, setDate) = React.useState(_ => Js.Date.make()) 

  let db = firestore()

  let onSelectDate = (d) => {
    setBooked(_ => false)
    setDate(_ => d)
  }

  let onSelectSlot = (d) => {
    setBooked(_ => true)
    setDate(_ => d)
  }

  let onBook = (b) => {
    set(. ref(. collection(. db, "bookings")), b)->ignore
    setProduct(_ => Booked)
  }

  let onHomeClick = (_) => {
    RescriptReactRouter.push("/")
  }

  // let onBookClick = (_) => {
  //   RescriptReactRouter.push("/service/" ++ serviceId ++ "/booking")
  // }

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
          setProduct(_ => Active({ ...service, id: serviceId }, schedule))
          Js.Promise.resolve(())
        }, get(. doc(. db, "experts", service.expert.id)))->ignore
      }
      Js.Promise.resolve(())
    }, get(. doc(. db, "services", serviceId))))->ignore 
    None
  })

  <main className="Book">
    <article className="Book-card">
      {switch product {
      | Loading => React.string("Loading...")
      | Empty => React.string("No data available")
      | Booked => {
        <section className="Booked">
          <img src=success alt="Success check mark" />
          <h1>{React.string(`Cita creada con éxito`)}</h1>
          <button className="Booked-outline" onClick=onHomeClick>{React.string("Agenda otra")}</button>
          // <a href="" className="Booked-link" onClick=onHomeClick>{React.string("Listado de servicios")}</a>
        </section>
      }
      | Active(item, spots) => {
        <>
          <aside className="Book-preview" style={ReactDOM.Style.make(~display="flex", ~flexWrap="wrap", ~alignItems="center", ~justifyContent="space-evenly", ~fontSize=".8em", ~padding="1em", ~maxWidth="calc(30vw - 150px)", ())}>
            <ServicePreview item />
            <ServiceForm date isBooked item onBook />
          </aside>
          <ServiceCalendar date onSelect=onSelectDate />
          <aside className="Book-slots" style={ReactDOM.Style.make(~display="flex", ~flexDirection="column", ~alignItems="center", ~justifyContent="flex-start", ~fontSize=".8em", ~padding="1em", ())}>
            <ServiceSlots date duration=item.duration spots onSelect=onSelectSlot />
          </aside>
          // <footer style={ReactDOM.Style.make(~textAlign="center", ())}>{React.string("Copyright Mist")}</footer>
        </>
        }
      }} 
    </article>
  </main>
}