import { NavLink } from "react-router-dom";
import "./Sidebar.css";

export default function Sidebar() {
  return (
    <aside className="sidebar">
      <h2>menu</h2>

      <nav>
        <NavLink to="/">Dashboard</NavLink>
        <NavLink to="/infra">Infra</NavLink>
        <NavLink to="/api">API</NavLink>
        <NavLink to="/auth">Auth</NavLink>
        <NavLink to="/about">About</NavLink>
      </nav>
    </aside>
  );
}
