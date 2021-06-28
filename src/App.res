%%raw(`import './App.css';`)

@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()
  
  switch url.path {
    | list{"service", serviceId, "booking"} => <ServiceBook serviceId />
    | _ => <ServiceSearch/>
  }
}
