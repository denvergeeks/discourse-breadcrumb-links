import { apiInitializer } from "discourse/lib/api";
import BreadCrumbs from "../components/breadcrumbs";
import config from "../lib/breadcrumb-config";

export default apiInitializer("1.14.0", (api) => {
  config.homeIcon = settings.home_icon || "d-icon-house";
  config.homeLabel = settings.home_label || "Home";
  config.homeUrl = settings.home_url || "/";

  api.renderInOutlet("above-main-container", BreadCrumbs);
});
