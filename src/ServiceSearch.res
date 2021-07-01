
%%raw(`import './ServiceSearch.css';`)

type user = {
  id: string,
  name: string,
  picture_url: string,
}

type service = {
  categories: array<string>,
  expert: user,
  desc: string,
  duration: int,
  type_: string,
  price: int,
  id: string,
}

type state = 
  | Empty 
  | Filtered(array<service>)

type intl

@scope("Intl") @val external numberFormat: ([#"es-CO" | #"es-MX" | #"en-US"], 'a) => intl = "NumberFormat"

@new @module("fuse.js") external fuse: (array<'a>, 'b) => 'c = "default"

@module("firebase/firestore") external firestore: unit => 'a = "getFirestore"

@module("firebase/firestore") external collection: (. 'a, string) => 'b = "collection"

@module("firebase/firestore") external doc: (. 'b) => Js.Promise.t<'c> = "getDocs"

@send external data: ('c, 'd) => service = "data"

@send external search: ('c, string) => array<'a> = "search"

@send external format: (intl, float) => string = "format"

let currencySettings = numberFormat(#"es-CO", {
  "style": "currency"
  "currency": "COP"
})

let currency = format(currencySettings)

module ServiceTile = {
  @react.component
  let make = (~item: service) => {
    let duration = if item.duration < 60 {
      Belt.Int.toString(item.duration) ++ "m"
    } else {
      Belt.Int.toString(item.duration / 60) ++ "h"
    }

    let onClick = (_) => {
      RescriptReactRouter.push("/service/" ++ item.id ++ "/booking")
    }

    <article className="Service" onClick>
      <figure className="Service-author">
        <img src={item.expert.picture_url} alt="Expert Picture Url" />
      </figure>
      <h2>{React.string(item.expert.name)}</h2>
      <p>{React.string(item.desc)}</p>
      <p className="Service-label">{React.string("Tiempo " ++ duration)}</p>
      <footer>
        <p className="Service-price">{React.string("Desde " ++ currency(Belt.Int.toFloat(item.price) /. 100.0))}</p>
      </footer>
    </article>
  }
}

@react.component
let make = () => {
  let (all, setAll) = React.useState(_ => []) 

  let (hits, setHits) = React.useState(_ => Empty) 

  let db = firestore()

  let onChange = (e) => {
    let q = ReactEvent.Form.target(e)["value"]
    if q == "" {
      setHits(_ => Empty)
    } else {
      let options = {
        "includeScore": true,
        "keys": ["categories", "desc", "expert.name"]
      }
      switch hits {
      | Empty
      | Filtered(_) => {
          let f = fuse(all, options)
          let h = search(f, q)
          setHits(_ => Filtered(Belt.Array.map(h, o => o["item"])))
        }
      }
    }
  }

  let searchHits = switch hits {
  | Empty => all
  | Filtered(result) => result
  }

  React.useEffect0(() => {
    Js.Promise.then_((querySnapshot) => {
      if !querySnapshot["empty"] {
        let results = Belt.Array.map(querySnapshot["docs"], d => {
          let data = data(d, {
            "serverTimestamps": "none"
          })
          {...data, id: d["id"]}
        })
        setAll(_ => results)
      }
      Js.Promise.resolve(())
    }, doc(. collection(. db, "services")))->ignore
    None
  })

  <main className="App">
    <header className="App-header">
      <input type_="search" onChange />
    </header>
    <article className="App-results">{Belt.Array.map(searchHits, item => <ServiceTile key={item.id} item />)->React.array}</article>
  </main>
}
