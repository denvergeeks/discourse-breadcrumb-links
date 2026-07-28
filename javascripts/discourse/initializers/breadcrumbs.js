import { apiInitializer } from "discourse/lib/api";
import dIcon from "discourse-common/helpers/d-icon";
import BreadCrumbs from "../components/breadcrumbs";
import config from "../lib/breadcrumb-config";

export default apiInitializer("1.14.0", (api) => {
  config.homeIcon = settings.home_icon || house;
  config.homeLabel = settings.home_label || "Home";
  config.homeUrl = settings.home_url || "/";

  api.renderInOutlet("above-main-container", BreadCrumbs);
});
