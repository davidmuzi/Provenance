//
//  GLViewController.swift
//  Provenance TV
//
//  Created by David Muzi on 2015-09-12.
//  Copyright © 2015 Provenance. All rights reserved.
//

import Foundation
import GLKit

class GLViewController: GLKViewController {
    
    let emulatorCore: PVEmulatorCore
    var glContext: EAGLContext?
    var effect: GLKBaseEffect?
    
    var texture: GLuint = 0
    var textureCoordinates = [GLKVector2(), GLKVector2(), GLKVector2(), GLKVector2(), GLKVector2(), GLKVector2(), GLKVector2(), GLKVector2()]
    var vertices = [GLKVector3Make(-1.0, -1.0,  1.0), GLKVector3Make(-1.0, -1.0,  1.0), GLKVector3Make(-1.0, -1.0,  1.0), GLKVector3Make(-1.0, -1.0,  1.0)]
    var triangleVertices = [GLKVector3(), GLKVector3(), GLKVector3(), GLKVector3(), GLKVector3(), GLKVector3()]
    var triangleTexCoords = [GLKVector2(), GLKVector2(), GLKVector2(), GLKVector2(), GLKVector2(), GLKVector2()]

    init (emulatorCore: PVEmulatorCore) {

        self.emulatorCore = emulatorCore
        
        super.init(nibName: nil, bundle: nil)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        
        preferredFramesPerSecond = 60
        
        glContext = EAGLContext(API: .OpenGLES2)
        EAGLContext.setCurrentContext(glContext)
        
        if let glView = self.view as? GLKView {
            
            glView.context = glContext!
        }
        
        effect = GLKBaseEffect()
        
        setupTexture()
    }
    
    override func glkView(view: GLKView, drawInRect rect: CGRect) {
        
        guard let effect = effect else {
            return
        }
        
        //@synchronized(self.emulatorCore) {
            glClearColor(1.0, 1.0, 1.0, 1.0)
            glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
            
            let screenSize = emulatorCore.screenRect().size
            let bufferSize = emulatorCore.bufferSize
            
            let texWidth = (screenSize.width / bufferSize().width)
            let texHeight = (screenSize.height / bufferSize().height)
            
            vertices[0] = GLKVector3Make(-1.0, -1.0,  1.0) // Left  bottom
            vertices[1] = GLKVector3Make( 1.0, -1.0,  1.0) // Right bottom
            vertices[2] = GLKVector3Make( 1.0,  1.0,  1.0) // Right top
            vertices[3] = GLKVector3Make(-1.0,  1.0,  1.0) // Left  top
            
            textureCoordinates[0] = GLKVector2Make(0.0, Float(texHeight)) // Left bottom
            textureCoordinates[1] = GLKVector2Make(Float(texWidth), Float(texHeight)) // Right bottom
            textureCoordinates[2] = GLKVector2Make(Float(texWidth), 0.0) // Right top
            textureCoordinates[3] = GLKVector2Make(0.0, 0.0) // Left top
            
            let vertexIndices = [
                // Front
                0, 1, 2,
                0, 2, 3,
            ]
        
            for var i = 0; i < 6; i++ {
                triangleVertices[i]  = vertices[vertexIndices[i]];
                triangleTexCoords[i] = textureCoordinates[vertexIndices[i]];
            }
            
            glBindTexture(GLenum(GL_TEXTURE_2D), texture);
            glTexSubImage2D(GLenum(GL_TEXTURE_2D), 0, 0, 0, GLsizei(emulatorCore.bufferSize().width), GLsizei(emulatorCore.bufferSize().height), emulatorCore.pixelFormat(), emulatorCore.pixelType(), emulatorCore.videoBuffer());
            
            if texture != 0
            {
                effect.texture2d0.envMode = .Replace;
                effect.texture2d0.target = .Target2D;
                effect.texture2d0.name = texture;
                effect.texture2d0.enabled = 1;
                effect.useConstantColor = 1;
            }
            
            effect.prepareToDraw();
            
            glDisable(GLenum(GL_DEPTH_TEST));
            glDisable(GLenum(GL_CULL_FACE));
            
            glEnableVertexAttribArray(GLuint(GLKVertexAttrib.Position.rawValue));
            glVertexAttribPointer(GLuint(GLKVertexAttrib.Position.rawValue), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, triangleVertices);
            
            if texture != 0
            {
                glEnableVertexAttribArray(GLuint(GLKVertexAttrib.TexCoord0.rawValue));
                glVertexAttribPointer(GLuint(GLKVertexAttrib.TexCoord0.rawValue), 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, triangleTexCoords);
            }
            
            glDrawArrays(GLenum(GL_TRIANGLES), 0, 6);
            
            if texture != 0
            {
                glDisableVertexAttribArray(GLuint(GLKVertexAttrib.TexCoord0.rawValue));
            }
            
            glDisableVertexAttribArray(GLuint(GLKVertexAttrib.Position.rawValue));
       // }

    }
    
    func setupTexture() {
        
        glGenTextures(1, &texture);
        glBindTexture(GLenum(GL_TEXTURE_2D), texture);
        glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GLint(emulatorCore.internalPixelFormat()), GLsizei(emulatorCore.bufferSize().width), GLsizei(emulatorCore.bufferSize().height), 0, emulatorCore.pixelFormat(), emulatorCore.pixelType(), emulatorCore.videoBuffer());
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_NEAREST);
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_NEAREST);
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE);
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_CLAMP_TO_EDGE);
    }
}