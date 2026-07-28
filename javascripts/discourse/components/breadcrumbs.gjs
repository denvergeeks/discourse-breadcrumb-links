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

  get homeIcon() {
    return config.homeIcon;
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
                <svg class="svg-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 640"><!--!Font Awesome Free 7.2.0 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license/free Copyright 2026 Fonticons, Inc.--><path d="M304 70.1C313.1 61.9 326.9 61.9 336 70.1L568 278.1C577.9 286.9 578.7 302.1 569.8 312C560.9 321.9 545.8 322.7 535.9 313.8L527.9 306.6L527.9 511.9C527.9 547.2 499.2 575.9 463.9 575.9L175.9 575.9C140.6 575.9 111.9 547.2 111.9 511.9L111.9 306.6L103.9 313.8C94 322.6 78.9 321.8 70 312C61.1 302.2 62 287 71.8 278.1L304 70.1zM320 120.2L160 263.7L160 512C160 520.8 167.2 528 176 528L224 528L224 424C224 384.2 256.2 352 296 352L344 352C383.8 352 416 384.2 416 424L416 528L464 528C472.8 528 480 520.8 480 512L480 263.7L320 120.3zM272 528L368 528L368 424C368 410.7 357.3 400 344 400L296 400C282.7 400 272 410.7 272 424L272 528z"/></svg>
              {{else}}
                <a href="{{this.homeUrl}}">
                  {{dIcon this.homeIcon}}
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
