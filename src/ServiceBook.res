
%%raw(`import './ServiceBook.css';`)

type lang

type options = {
  locale: lang 
}

@module("date-fns") external format: ('a, string, options) => string = "format"

@module("date-fns") external startMonth: 'a => 'a = "startOfMonth"

@module("date-fns") external daysInMonth: 'a => int = "getDaysInMonth"

@module("date-fns") external dayOfYear: 'a => int = "getDayOfYear"

@module("date-fns") external addDays: ('a, int) => 'a = "addDays"

@module("date-fns") external sunday: 'a => bool = "isSunday"

@module("date-fns") external monday: 'a => bool = "isMonday"

@module("date-fns") external tuesday: 'a => bool = "isTuesday"

@module("date-fns") external wednesday: 'a => bool = "isWednesday"

@module("date-fns") external thursday: 'a => bool = "isThursday"

@module("date-fns") external friday: 'a => bool = "isFriday"

@module("date-fns") external saturday: 'a => bool = "isSaturday"

@module("date-fns/locale") external es: lang = "es"

@react.component
let make = () => {
  let (date, setDate) = React.useState(_ => Js.Date.make()) 

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

  let days = Belt.Array.makeByU(daysInMonth(date), (. i) => addDays(start, i))

  <main className="Book">
    <article className="Book-card">
      <aside>{React.string("Service preview and input data")}</aside>
      <section className="Calendar">
        <h3 className="Calendar-month">{React.string(Js.String.charAt(0, month)->Js.String.toUpperCase ++ Js.String.sliceToEnd(~from=1, month))}</h3>
	<div className="Calendar-dow">
	  <div>{React.string("Su")}</div>
	  <div>{React.string("Mo")}</div>
	  <div>{React.string("Tu")}</div>
	  <div>{React.string("We")}</div>
	  <div>{React.string("Th")}</div>
	  <div>{React.string("Fr")}</div>
	  <div>{React.string("Sa")}</div>
	</div>
	<div className="Calendar-grid">
	  {Belt.Array.map(days, d => <button key={Js.Int.toString(dayOfYear(d))} className={dowClass(d)}><time dateTime={format(d, "y-MM-dd", esOptions)}>{React.string(format(d, "d", esOptions))}</time></button>)->React.array}
	</div>
      </section>
      <aside>{React.string("Available spots")}</aside>
      <footer>{React.string("Comfirmation")}</footer>
    </article>
  </main>
}