// メニュー操作

// トグルリスナーを追加する
const addToggleListener = (selecter_id, menu_id, toggle_class) => {
  let selected_element = document.querySelector(`#${selecter_id}`);
  selected_element.addEventListener("click", (e) => {
    e.preventDefault();
    let menu = document.querySelector(`#${menu_id}`);
    menu.classList.toggle(toggle_class);
  });
};

// クリックをリッスンするトグルリスナーを追加する
document.addEventListener("turbo:load", () => {
  addToggleListener("hamburger", "navbar-menu",   "collapse");
  addToggleListener("account",   "dropdown-menu", "active");  
});
