import { apiInitializer } from "discourse/lib/api";
import BreadCrumbLinks from "../components/breadcrumbLinks";

export default apiInitializer("1.14.0", (api) => {
  api.renderInOutlet("above-main-container", BreadCrumbLinks);
});
