%%raw(`import './App.css';`)

@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()
  
  switch url.path {
    // | list{"service", id, "booking"} => <ServiceBook id />
    // | _ => <ServiceSearch/>
    | _ => <ServiceBook/>
  }
}
