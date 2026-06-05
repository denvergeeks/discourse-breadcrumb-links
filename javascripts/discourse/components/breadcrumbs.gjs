import Component from "@glimmer/component";
import { service } from "@ember/service";
import bodyClass from "discourse/helpers/body-class";
import { defaultHomepage } from "discourse/lib/utilities";
import Category from "discourse/models/category";
import dIcon from "discourse-common/helpers/d-icon";
import i18n from "discourse-common/helpers/i18n";
import config from "../lib/breadcrumb-config";

export default class Breadcrumbs extends Component {
  @service router;

  get homePage() {
    return this.router.currentRouteName === `discovery.${defaultHomepage()}`;
  }

  get isTopic() {
    return this.router.currentRouteName.startsWith("topic");
  }

  // Topic model is loaded by the "topic" route; currentRoute is the child (e.g. "topic.fromParams")
  get topicModel() {
    if (!this.isTopic) return null;
    const parent = this.router.currentRoute?.parent?.attributes;
    if (parent?.title !== undefined) return parent;
    return this.router.currentRoute?.attributes ?? null;
  }

  get topicCategory() {
    const id = this.topicModel?.category_id;
    return id ? Category.findById(id) : null;
  }

  get topicParentCategory() {
    return this.topicCategory?.parentCategory ?? null;
  }

  get topicParentCategoryLink() {
    return this.topicParentCategory
      ? `/c/${this.topicParentCategory.slug}`
      : null;
  }

  get topicCategoryLink() {
    if (!this.topicCategory) return null;
    return this.topicParentCategory
      ? `/c/${this.topicParentCategory.slug}/${this.topicCategory.slug}`
      : `/c/${this.topicCategory.slug}`;
  }

  get currentPage() {
    if (this.isTopic) {
      return this.topicModel?.title ?? null;
    }

    switch (true) {
      case this.router.currentRouteName.includes("userPrivateMessages"):
        return i18n("js.groups.messages");
      case this.router.currentRouteName.startsWith("admin"):
        return i18n("js.admin_title");
      case this.router.currentRouteName === "userNotifications.responses" ||
        this.router.currentRouteName === "userNotifications.mentions":
        return i18n("js.groups.mentions");
      case this.router.currentRouteName === "userActivity.bookmarks":
        return i18n("js.user.bookmarks");
      case this.router.currentRoute?.parent?.name === "docs":
        return i18n("js.docs.title");
      case this.router.currentRoute?.parent?.name === "preferences":
        return i18n("js.user.preferences.title");
      case this.router.currentRouteName ===
        "discourse-post-event-upcoming-events.index":
        return i18n("js.discourse_post_event.upcoming_events.title");
      case this.router.currentRouteName === "tags.index":
        return i18n("js.tagging.all_tags");
      case this.router.currentRouteName.includes("Category") ||
        this.router.currentRouteName.includes("category"):
        return this.categoryName;
      default:
        return null;
    }
  }

  // For category pages: parent category name. For topic pages: the topic's category name.
  get parentPage() {
    if (this.isTopic) {
      return this.topicCategory?.name ?? null;
    }

    switch (true) {
      case this.router.currentRouteName.includes("category") ||
        this.router.currentRouteName.includes("Category"):
        return this.parentCategoryName;
      default:
        return null;
    }
  }

  // Only set on topic pages when the topic's category is itself a subcategory.
  get grandParentPage() {
    return this.isTopic ? (this.topicParentCategory?.name ?? null) : null;
  }

  get currentCategory() {
    const slugPath =
      this.router.currentRoute?.params?.category_slug_path_with_id;
    return slugPath ? Category.findBySlugPathWithID(slugPath) : null;
  }

  get categoryName() {
    return this.currentCategory?.name ?? null;
  }

  get parentCategory() {
    const id = this.currentCategory?.parentCategory?.id;
    return id ? Category.findById(id) : null;
  }

  get parentCategoryName() {
    return this.parentCategory?.name ?? null;
  }

  get parentCategoryLink() {
    return this.parentCategory?.slug ?? null;
  }

  get homeLabel() {
    return config.homeLabel;
  }

  get homeUrl() {
    return config.homeUrl;
  }

  <template>
    {{#if this.currentPage}}
      {{bodyClass "has-breadcrumbs"}}
      <div class="breadcrumbs">
        <div class="breadcrumbs__container">
          <ul class="breadcrumbs__links">

            <li class="home">
              {{#if this.homePage}}
                {{this.homeLabel}}
              {{else}}
                <a href="{{this.homeUrl}}">
                  <span class="breadcrumbs__title">
                    {{dIcon "arrow-left"}}
                  </span>
                  {{this.homeLabel}}
                </a>
              {{/if}}
            </li>

            {{! Topic in a subcategory: Home → Parent Cat → Subcat → Topic }}
            {{#if this.grandParentPage}}
              <li class="parent">
                <a href="{{this.topicParentCategoryLink}}">
                  {{this.grandParentPage}}
                </a>
              </li>
            {{/if}}

            {{#if this.parentPage}}
              <li class="parent">
                {{#if this.isTopic}}
                  <a href="{{this.topicCategoryLink}}">{{this.parentPage}}</a>
                {{else}}
                  <a href="/c/{{this.parentCategoryLink}}">{{this.parentPage}}</a>
                {{/if}}
              </li>
            {{/if}}

            <li class="current {{if this.isTopic "topic"}}">
              {{this.currentPage}}
            </li>

          </ul>
        </div>
      </div>
    {{/if}}
  </template>
}
