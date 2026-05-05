# FAQs

- [x] Hỗ trợ lệnh gọn hơn như `gt setup multi zoxide mcfly fzf direnv`
- [ ] Tham khảo [examples](https://github.com/bashly-framework/bashly/tree/master/examples), configuration, advanced features trên bashly để upgrade code hiện đại, tối ưu hơn
- [x] Việc dùng eval setup tools vậy có vấn đề không ? bạn dùng giải pháp tối ưu hơn là làm các plugin zsh thì sẽ setup tiện hơn
- [ ] Viết guide hướng dẫn cho các tools
- [ ] Viết docker compose để có môi trường test các tools
- [x] Hiện bạn đang load zsh plugin /home/ubuntu/workspace/devops/kube-gtelots/os-scripts. Tuy nhiên giải pháp này rủi ro nếu tôi xóa source code => **Giải pháp**: Copy các local zsh plugins từ `src/zsh-plugins` vào `~/.config/gt/zsh-plugins` trong lúc cài đặt `antidote`, và cấu hình `.zsh_plugins.txt` đọc từ đó thay vì đọc trực tiếp từ source code.