%%raw(`import './App.css';`)

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

@new @module("fuse.js") external fuse: (array<'a>, 'b) => 'c = "default"

@module("firebase/firestore") external firestore: unit => 'a = "getFirestore"

@module("firebase/firestore") external collection: (. 'a, string) => 'b = "collection"

@module("firebase/firestore") external doc: (. 'b) => Js.Promise.t<'c> = "getDocs"

@send external data: ('c, 'd) => service = "data"

@send external search: ('c, string) => array<'a> = "search"

type state = 
  | Empty 
  | Filtered(array<service>)

module ServiceTile = {
  @react.component
  let make = (~item: service) => {
    <p key={item.id} className="myLabel"> {React.string(item.desc)} </p>
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

  <div className="App">
    <header className="App-header">
      <input type_="search" onChange />
    </header>
    <section className="App-results">{Belt.Array.map(searchHits, item => <ServiceTile item />)->React.array}</section>
  </div>
}
