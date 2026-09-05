import { Link } from "react-router-dom";
import { EmptyState } from "../components/EmptyState";

export function NotFoundPage() {
  return <div className="not-found"><EmptyState title="Page not found" detail="This page may have moved or your role may not have access." /><Link className="primary-button" to="/">Back to overview</Link></div>;
}
