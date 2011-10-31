require 'Qt'
require 'disp3D'

include Disp3D
class QtWidgetGL < Qt::GLWidget
  attr_accessor :width
  attr_accessor :height

  def initialize(parent)
    super(parent)
    @width = 400
    @height = 400

    @min_width = 50
    @min_height = 50
  end

  def dispose()
    super
  end

  def camera
    return @view.camera
  end

  def world_scene_graph
    return @view.world_scene_graph
  end

  def fit
    @view.fit
  end

  def initializeGL()
    @view = Disp3D::GLView.new(@width, @height)
  end

  def minimumSizeHint()
    return Qt::Size.new(@min_width, @min_height)
  end

  def sizeHint()
    return Qt::Size.new(@width, @height)
  end

  def get_GLUT_button(event)
    return GLUT::GLUT_RIGHT_BUTTON if( event.button == Qt::RightButton)
    return GLUT::GLUT_LEFT_BUTTON if( event.button == Qt::LeftButton)
    return nil
  end

  def mouseReleaseEvent(event)
    @mouse_release_proc.call(self, get_GLUT_button(event), event.pos.x, event.pos.y) if( @mouse_release_proc != nil)
    @view.manipulator.mouse(get_GLUT_button(event), GLUT::GLUT_UP, event.pos.x,event.pos.y)
  end

  def mousePressEvent(event)
    @mouse_press_proc.call(self, get_GLUT_button(event), event.pos.x, event.pos.y) if( @mouse_press_proc != nil)
    @view.manipulator.mouse(get_GLUT_button(event), GLUT::GLUT_DOWN, event.pos.x,event.pos.y)
  end

  def mouseMoveEvent(event)
    @mouse_move_proc.call(self, x,y) if( @mouse_move_proc != nil)

    need_update = @view.manipulator.motion(event.pos.x,event.pos.y)
    if(need_update)
      updateGL()
    end
  end

  def paintGL
    @view.display
  end

  def resizeGL(width, height)
    @view.camera.reshape(width, height)
    @view.manipulator.reset_size(width, height)
  end
end

