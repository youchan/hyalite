module Hyalite
  class SimpleEventPlugin
    EVENT_TYPES = {
      blur: {
        phasedRegistrationNames: {
          bubbled: :onBlur,
          captured: :onBlurCapture
        }
      },
      click: {
        phasedRegistrationNames: {
          bubbled: :onClick,
          captured: :onClickCapture
        }
      },
      contextMenu: {
        phasedRegistrationNames: {
          bubbled: :onContextMenu,
          captured: :onContextMenuCapture
        }
      },
      copy: {
        phasedRegistrationNames: {
          bubbled: :onCopy,
          captured: :onCopyCapture
        }
      },
      cut: {
        phasedRegistrationNames: {
          bubbled: :onCut,
          captured: :onCutCapture
        }
      },
      doubleClick: {
        phasedRegistrationNames: {
          bubbled: :onDoubleClick,
          captured: :onDoubleClickCapture
        }
      },
      drag: {
        phasedRegistrationNames: {
          bubbled: :onDrag,
          captured: :onDragCapture
        }
      },
      dragEnd: {
        phasedRegistrationNames: {
          bubbled: :onDragEnd,
          captured: :onDragEndCapture
        }
      },
      dragEnter: {
        phasedRegistrationNames: {
          bubbled: :onDragEnter,
          captured: :onDragEnterCapture
        }
      },
      dragExit: {
        phasedRegistrationNames: {
          bubbled: :onDragExit,
          captured: :onDragExitCapture
        }
      },
      dragLeave: {
        phasedRegistrationNames: {
          bubbled: :onDragLeave,
          captured: :onDragLeaveCapture
        }
      },
      dragOver: {
        phasedRegistrationNames: {
          bubbled: :onDragOver,
          captured: :onDragOverCapture
        }
      },
      dragStart: {
        phasedRegistrationNames: {
          bubbled: :onDragStart,
          captured: :onDragStartCapture
        }
      },
      drop: {
        phasedRegistrationNames: {
          bubbled: :onDrop,
          captured: :onDropCapture
        }
      },
      focus: {
        phasedRegistrationNames: {
          bubbled: :onFocus,
          captured: :onFocusCapture
        }
      },
      focusin: {
        phasedRegistrationNames: {
          bubbled: :onFocusIn,
          captured: :onFocusInCapture
        }
      },
      focusout: {
        phasedRegistrationNames: {
          bubbled: :onFocusOut,
          captured: :onFocusOutCapture
        }
      },
      input: {
        phasedRegistrationNames: {
          bubbled: :onInput,
          captured: :onInputCapture
        }
      },
      keyDown: {
        phasedRegistrationNames: {
          bubbled: :onKeyDown,
          captured: :onKeyDownCapture
        }
      },
      keyPress: {
        phasedRegistrationNames: {
          bubbled: :onKeyPress,
          captured: :onKeyPressCapture
        }
      },
      keyUp: {
        phasedRegistrationNames: {
          bubbled: :onKeyUp,
          captured: :onKeyUpCapture
        }
      },
      load: {
        phasedRegistrationNames: {
          bubbled: :onLoad,
          captured: :onLoadCapture
        }
      },
      error: {
        phasedRegistrationNames: {
          bubbled: :onError,
          captured: :onErrorCapture
        }
      },
      mouseDown: {
        phasedRegistrationNames: {
          bubbled: :onMouseDown,
          captured: :onMouseDownCapture
        }
      },
      mouseMove: {
        phasedRegistrationNames: {
          bubbled: :onMouseMove,
          captured: :onMouseMoveCapture
        }
      },
      mouseOut: {
        phasedRegistrationNames: {
          bubbled: :onMouseOut,
          captured: :onMouseOutCapture
        }
      },
      mouseOver: {
        phasedRegistrationNames: {
          bubbled: :onMouseOver,
          captured: :onMouseOverCapture
        }
      },
      mouseUp: {
        phasedRegistrationNames: {
          bubbled: :onMouseUp,
          captured: :onMouseUpCapture
        }
      },
      paste: {
        phasedRegistrationNames: {
          bubbled: :onPaste,
          captured: :onPasteCapture
        }
      },
      reset: {
        phasedRegistrationNames: {
          bubbled: :onReset,
          captured: :onResetCapture
        }
      },
      scroll: {
        phasedRegistrationNames: {
          bubbled: :onScroll,
          captured: :onScrollCapture
        }
      },
      submit: {
        phasedRegistrationNames: {
          bubbled: :onSubmit,
          captured: :onSubmitCapture
        }
      },
      touchCancel: {
        phasedRegistrationNames: {
          bubbled: :onTouchCancel,
          captured: :onTouchCancelCapture
        }
      },
      touchEnd: {
        phasedRegistrationNames: {
          bubbled: :onTouchEnd,
          captured: :onTouchEndCapture
        }
      },
      touchMove: {
        phasedRegistrationNames: {
          bubbled: :onTouchMove,
          captured: :onTouchMoveCapture
        }
      },
      touchStart: {
        phasedRegistrationNames: {
          bubbled: :onTouchStart,
          captured: :onTouchStartCapture
        }
      },
      wheel: {
        phasedRegistrationNames: {
          bubbled: :onWheel,
          captured: :onWheelCapture
        }
      }
    }

    TOP_LEVEL_EVENTS_TO_DISPATCH_CONFIG = {
      topBlur: EVENT_TYPES[:blur],
      topClick: EVENT_TYPES[:click],
      topContextMenu: EVENT_TYPES[:contextMenu],
      topCopy: EVENT_TYPES[:copy],
      topCut: EVENT_TYPES[:cut],
      topDoubleClick: EVENT_TYPES[:doubleClick],
      topDrag: EVENT_TYPES[:drag],
      topDragEnd: EVENT_TYPES[:dragEnd],
      topDragEnter: EVENT_TYPES[:dragEnter],
      topDragExit: EVENT_TYPES[:dragExit],
      topDragLeave: EVENT_TYPES[:dragLeave],
      topDragOver: EVENT_TYPES[:dragOver],
      topDragStart: EVENT_TYPES[:dragStart],
      topDrop: EVENT_TYPES[:drop],
      topError: EVENT_TYPES[:error],
      topFocus: EVENT_TYPES[:focus],
      topFocusIn: EVENT_TYPES[:focusin],
      topFocusOut: EVENT_TYPES[:focusout],
      topInput: EVENT_TYPES[:input],
      topKeyDown: EVENT_TYPES[:keyDown],
      topKeyPress: EVENT_TYPES[:keyPress],
      topKeyUp: EVENT_TYPES[:keyUp],
      topLoad: EVENT_TYPES[:load],
      topMouseDown: EVENT_TYPES[:mouseDown],
      topMouseMove: EVENT_TYPES[:mouseMove],
      topMouseOut: EVENT_TYPES[:mouseOut],
      topMouseOver: EVENT_TYPES[:mouseOver],
      topMouseUp: EVENT_TYPES[:mouseUp],
      topPaste: EVENT_TYPES[:paste],
      topReset: EVENT_TYPES[:reset],
      topScroll: EVENT_TYPES[:scroll],
      topSubmit: EVENT_TYPES[:submit],
      topTouchCancel: EVENT_TYPES[:touchCancel],
      topTouchEnd: EVENT_TYPES[:touchEnd],
      topTouchMove: EVENT_TYPES[:touchMove],
      topTouchStart: EVENT_TYPES[:touchStart],
      topWheel: EVENT_TYPES[:wheel]
    }

    def initialize
      TOP_LEVEL_EVENTS_TO_DISPATCH_CONFIG.each do |type, dispatch_config|
        dispatch_config[:dependencies] = [type]
      end
    end

    def event_types
      EVENT_TYPES
    end

    def extract_event(top_level_type, top_level_target, top_level_target_id, event)
      dispatch_config = TOP_LEVEL_EVENTS_TO_DISPATCH_CONFIG[top_level_type]
      return [] unless dispatch_config

      SyntheticEvent.new(event).tap do |synthetic_event|
        InstanceHandles.traverse_two_phase(top_level_target_id) do |target_id, upwards|
          listener = BrowserEvent.listener_at_phase(target_id, dispatch_config, upwards ? :bubbled : :captured)
          synthetic_event.add_listener(listener, target_id) if listener
        end
      end
    end
  end
end
