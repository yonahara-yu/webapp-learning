import { BrowserRouter, Routes, Route } from "react-router-dom";
import Layout from "./components/Layout";
import Dashboard from "./pages/Dashboard";
import Infra from "./pages/Infra";
import Api from "./pages/Api";
import Auth from "./pages/Auth";
import About from "./pages/About";

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route element={<Layout />}>
          <Route path="/" element={<Dashboard />} />
          <Route path="/infra" element={<Infra />} />
          <Route path="/api" element={<Api />} />
          <Route path="/auth" element={<Auth />} />
          <Route path="/about" element={<About />} />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}

export default App;
