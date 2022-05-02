// 
// Copyright 2022 Clemens Cords
// Created on 02.05.22 by clem (mail@clemens-cords.com)
//

#include <input_handler.hpp>
#include <render_window.hpp>
#include <jluna.hpp>

namespace game
{
    void InputHandler::load_button_mapping()
    {
        using namespace jluna;
        Module binding = Main["settings"]["keyboard_bindings"];

        _mapping.emplace(sf::Keyboard::Key(static_cast<Int64>(binding["A"])), Key::A);
        _mapping.emplace(sf::Keyboard::Key(static_cast<Int64>(binding["B"])), Key::B);
        _mapping.emplace(sf::Keyboard::Key(static_cast<Int64>(binding["X"])), Key::X);
        _mapping.emplace(sf::Keyboard::Key(static_cast<Int64>(binding["Y"])), Key::Y);
        _mapping.emplace(sf::Keyboard::Key(static_cast<Int64>(binding["START"])), Key::START);
        _mapping.emplace(sf::Keyboard::Key(static_cast<Int64>(binding["SELECT"])), Key::SELECT);
        _mapping.emplace(sf::Keyboard::Key(static_cast<Int64>(binding["UP"])), Key::UP);
        _mapping.emplace(sf::Keyboard::Key(static_cast<Int64>(binding["DOWN"])), Key::DOWN);
        _mapping.emplace(sf::Keyboard::Key(static_cast<Int64>(binding["LEFT"])), Key::LEFT);
        _mapping.emplace(sf::Keyboard::Key(static_cast<Int64>(binding["RIGHT"])), Key::RIGHT);

        _state.emplace(Key::A, KeyState());
        _state.emplace(Key::B, KeyState());
        _state.emplace(Key::X, KeyState());
        _state.emplace(Key::Y, KeyState());
        _state.emplace(Key::START, KeyState());
        _state.emplace(Key::SELECT, KeyState());
        _state.emplace(Key::UP, KeyState());
        _state.emplace(Key::DOWN, KeyState());
        _state.emplace(Key::LEFT, KeyState());
        _state.emplace(Key::RIGHT, KeyState());
    }

    void InputHandler::update(sf::Window& render_window)
    {
        for (auto pair : _state)
        {
            pair.second.down_last_frame = pair.second.down_this_frame;
            pair.second.down_this_frame = false;
        }

        auto event = sf::Event();
        using Type = sf::Event::EventType;
        while (render_window.pollEvent(event))
        {
            if(event.type == Type::Closed)
                render_window.close();
            else if (event.type == Type::KeyPressed)
            {
                auto it = _mapping.find(event.key.code);
                if (it != _mapping.end())
                {
                    _state[it->second].down_this_frame = true;
                    _state[it->second].duration += window_config::frame_duration;
                }
                break;
            }
            else if (event.type == Type::KeyReleased)
            {
                auto it = _mapping.find(event.key.code);
                if (it != _mapping.end())
                {
                    _state[it->second].down_this_frame = false;
                    _state[it->second].duration = sf::seconds(0);
                }
                break;
            }
        }
    }

    bool InputHandler::is_key_down(game::Key key)
    {
        return _state[key].down_this_frame;
    }

    bool InputHandler::has_state_changed(game::Key key)
    {
        auto state = _state[key];
        return state.down_this_frame != state.down_last_frame;
    }

    bool InputHandler::was_key_pressed(game::Key key)
    {
        return has_state_changed(key) and is_key_down(key);
    }

    bool InputHandler::was_key_released(game::Key key)
    {
        return has_state_changed(key) and not is_key_down(key);
    }

    sf::Time InputHandler::get_hold_duration(game::Key key)
    {
        return _state[key].duration;
    }
}

